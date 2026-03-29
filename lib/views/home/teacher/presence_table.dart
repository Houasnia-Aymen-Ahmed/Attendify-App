import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/code_request.dart';
import 'package:attendify/models/live_session.dart';
import 'package:attendify/models/session_check_in.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/services/providers.dart';
import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/theme/attendify_ui.dart';
import 'package:attendify/utils/module_metrics.dart';
import 'package:attendify/models/module_model.dart';

class PresenceTable extends ConsumerStatefulWidget {
  final List<Student> students;
  final Module module;
  final DatabaseService databaseService;

  const PresenceTable({
    super.key,
    required this.students,
    required this.module,
    required this.databaseService,
  });

  @override
  ConsumerState<PresenceTable> createState() => _PresenceTableState();
}

class _PresenceTableState extends ConsumerState<PresenceTable> {
  bool _isMutatingSession = false;

  // Ticks every second so countdowns refresh automatically
  Timer? _ticker;

  List<String> get _studentIds =>
      widget.students.map((s) => s.uid).toList();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) { if (mounted) setState(() {}); },
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ── Session lifecycle ──────────────────────────────────────────────────────

  Future<void> _startLiveSession() async {
    final config = await _showStartSessionDialog();
    if (config == null) return;

    setState(() => _isMutatingSession = true);
    try {
      await ref.read(sessionServiceProvider).startSession(
            widget.module.uid,
            config.roomLabel,
            _studentIds,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Live session started.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isMutatingSession = false);
    }
  }

  Future<void> _stopLiveSession(String sessionId) async {
    setState(() => _isMutatingSession = true);
    try {
      await ref.read(sessionServiceProvider).stopSession(sessionId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session closed and attendance synced.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isMutatingSession = false);
    }
  }

  // ── Attendance codes ───────────────────────────────────────────────────────

  Future<void> _sendCodes(LiveSession session) async {
    setState(() => _isMutatingSession = true);
    try {
      await ref
          .read(sessionServiceProvider)
          .sendAttendanceCodes(session.id, session.eligibleStudentIds);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Codes sent to ${session.eligibleStudentIds.length} students. '
            'Tell them to mark presence now.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isMutatingSession = false);
    }
  }

  Future<void> _resendToStudents(
    LiveSession session,
    List<String> studentIds,
  ) async {
    setState(() => _isMutatingSession = true);
    try {
      await ref
          .read(sessionServiceProvider)
          .resendCodes(session.id, studentIds);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New codes sent to ${studentIds.length} student(s).')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isMutatingSession = false);
    }
  }

  // ── Export ─────────────────────────────────────────────────────────────────

  Future<void> _exportData(
    List<DataColumn> columns,
    List<DataRow> rows,
  ) async {
    final excelData = Excel.createExcel();
    final sheet = excelData['Sheet1'];

    for (var i = 0; i < columns.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue((columns[i].label as Text).data ?? '');
    }

    for (var i = 0; i < rows.length; i++) {
      for (var j = 0; j < rows[i].cells.length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
            .value =
            TextCellValue((rows[i].cells[j].child as Text).data ?? '');
      }
    }

    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;

    final path = '$result/${widget.module.name.replaceAll(' ', '_')}.xlsx';
    try {
      await File(path).writeAsBytes(excelData.encode()!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance table exported successfully.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while exporting attendance data.'),
        ),
      );
    }
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  Future<_LiveSessionConfig?> _showStartSessionDialog() async {
    final roomController = TextEditingController(text: widget.module.name);

    final result = await showDialog<_LiveSessionConfig>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Start live session'),
          content: TextField(
            controller: roomController,
            decoration: attendifyInputDecoration(
              hintText: 'Room 402',
              labelText: 'Room label',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (roomController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a room label.'),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop(
                  _LiveSessionConfig(roomLabel: roomController.text.trim()),
                );
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );

    roomController.dispose();
    return result;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _timeLabel(DateTime? value) {
    if (value == null) return '--:--';
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final todayDate = todayAttendanceKey();
    final dates = sortedAttendanceDates(widget.module, descending: false);

    final columns = <DataColumn>[
      const DataColumn(label: Text('Student ID')),
      const DataColumn(label: Text('Student Name')),
      ...dates.map((d) => DataColumn(label: Text(d))),
    ];

    final rows = List<DataRow>.generate(_studentIds.length, (index) {
      final studentId = _studentIds[index];
      return DataRow(cells: [
        DataCell(Text(studentId.substring(0, 4))),
        DataCell(Text(widget.students[index].userName)),
        ...dates.map(
          (date) => DataCell(
            Text((widget.module.attendanceTable[date] as Map?)?[studentId] as bool? ?? false
                ? 'Present'
                : 'Absent'),
          ),
        ),
      ]);
    });

    final activeSessionAsync =
        ref.watch(activeSessionProvider(widget.module.uid));

    return activeSessionAsync.when(
      data: (activeSession) {
        final checkInsAsync = activeSession == null
            ? const AsyncData<List<SessionCheckIn>>(<SessionCheckIn>[])
            : ref.watch(sessionCheckInsProvider(activeSession.id));

        final codeRequestsAsync = activeSession == null
            ? const AsyncData<List<CodeRequest>>(<CodeRequest>[])
            : ref.watch(codeRequestsProvider(activeSession.id));

        return checkInsAsync.when(
          data: (checkIns) {
            final pendingRequests =
                codeRequestsAsync.asData?.value ?? <CodeRequest>[];

            final successfulCheckIns = checkIns
                .where((c) => c.status == SessionCheckInStatus.present)
                .toList();
            final latestCheckIns = successfulCheckIns.take(4).toList();
            final todayPresent = activeSession == null
                ? presentCountForDate(widget.module, todayDate)
                : successfulCheckIns.length;
            final attendanceRate =
                moduleAttendancePercentage(widget.module);
            final studentsById = {
              for (final s in widget.students) s.uid: s,
            };

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Session control ──────────────────────────────────────────
                AttendifySurface(
                  color: AttendifyPalette.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LIVE SESSION CONTROL',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        activeSession == null
                            ? 'Attendance is closed'
                            : 'Attendance is live',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activeSession == null
                            ? 'Start a live session when class begins. '
                                'Students will receive attendance codes on their devices.'
                            : 'Room ${activeSession.roomLabel} • '
                                'started at ${_timeLabel(activeSession.startedAt)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 18),
                      AttendifyPrimaryButton(
                        label: activeSession == null
                            ? 'Start live session'
                            : 'Stop live session',
                        icon: activeSession == null
                            ? Icons.play_arrow_rounded
                            : Icons.stop_rounded,
                        isLoading: _isMutatingSession,
                        onPressed: () => activeSession == null
                            ? _startLiveSession()
                            : _stopLiveSession(activeSession.id),
                      ),
                    ],
                  ),
                ),

                // ── Attendance codes (only when session is active) ───────────
                if (activeSession != null) ...[
                  const SizedBox(height: 16),
                  _buildCodesCard(activeSession, pendingRequests),
                ],

                const SizedBox(height: 16),

                // ── Metric cards ─────────────────────────────────────────────
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 700;
                    final itemWidth = wide
                        ? (constraints.maxWidth - 24) / 3
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: AttendifyMetricCard(
                            label: 'Students',
                            value: '${widget.students.length}',
                            helper: 'Registered in this module',
                            icon: Icons.groups_rounded,
                            emphasized: true,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: AttendifyMetricCard(
                            label: activeSession == null
                                ? 'Present today'
                                : 'Live check-ins',
                            value: '$todayPresent',
                            helper: activeSession == null
                                ? 'Sourced from the synced attendance table'
                                : 'Confirmed check-ins for this session',
                            icon: Icons.how_to_reg_rounded,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: AttendifyMetricCard(
                            label: 'Attendance rate',
                            value:
                                '${attendanceRate.toStringAsFixed(0)}%',
                            helper:
                                '${widget.module.attendanceTable.length} '
                                'historical session entries',
                            icon: Icons.bar_chart_rounded,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 18),

                // ── Recent check-ins / records heading ───────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeSession == null
                                ? 'Attendance records'
                                : 'Recent live check-ins',
                            style:
                                Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeSession == null
                                ? 'Export the table or review historical presence by date.'
                                : 'Check-ins appear here as students confirm attendance.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: AttendifyPalette.mutedText),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _exportData(columns, rows),
                      icon: const Icon(Icons.file_download_rounded),
                      label: const Text('Export'),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                if (activeSession != null) ...[
                  if (latestCheckIns.isEmpty)
                    const AttendifySurface(
                      child: Text(
                        'No students have checked in yet for this live session.',
                      ),
                    )
                  else
                    ...latestCheckIns.map((checkIn) {
                      final student = studentsById[checkIn.studentId];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AttendifySurface(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student?.userName ??
                                          checkIn.studentId,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Checked in at ${_timeLabel(checkIn.checkedInAt)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AttendifyPalette
                                                .mutedText,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              AttendifyStatusChip(
                                label: _timeLabel(checkIn.checkedInAt),
                                color: AttendifyPalette.secondary,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 10),
                ],

                // ── Attendance table ─────────────────────────────────────────
                Expanded(
                  child: AttendifySurface(
                    padding: const EdgeInsets.all(14),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: columns,
                            rows: rows,
                            dataRowMinHeight: 52,
                            dataRowMaxHeight: 64,
                            headingRowColor: const WidgetStatePropertyAll(
                              AttendifyPalette.surfaceMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }

  // ── Attendance codes card ──────────────────────────────────────────────────

  Widget _buildCodesCard(
    LiveSession session,
    List<CodeRequest> pendingRequests,
  ) {
    final codesIssuedAt = session.codesIssuedAt;
    final int secondsLeft;

    if (codesIssuedAt == null) {
      secondsLeft = 0;
    } else {
      final elapsed =
          DateTime.now().difference(codesIssuedAt).inSeconds;
      secondsLeft = (60 - elapsed).clamp(0, 60);
    }

    final codesActive = secondsLeft > 0;

    return AttendifySurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ATTENDANCE CODES',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AttendifyPalette.mutedText),
          ),
          const SizedBox(height: 10),

          if (!codesActive) ...[
            Text(
              codesIssuedAt == null
                  ? 'No codes sent yet. When ready, send codes and tell students to mark their presence.'
                  : 'Codes expired. Send a new batch whenever you want students to check in again.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            AttendifyPrimaryButton(
              label: codesIssuedAt == null ? 'Send Codes' : 'Send New Codes',
              icon: Icons.send_rounded,
              isLoading: _isMutatingSession,
              onPressed: () => _sendCodes(session),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Codes active — $secondsLeft seconds remaining',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: secondsLeft / 60,
                          minHeight: 6,
                          backgroundColor: AttendifyPalette.surfaceMuted,
                          color: AttendifyPalette.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _isMutatingSession
                      ? null
                      : () => _sendCodes(session),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Resend All'),
                ),
              ],
            ),
          ],

          // Pending resend requests
          if (pendingRequests.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              '${pendingRequests.length} '
              '${pendingRequests.length == 1 ? 'student needs' : 'students need'} '
              'a new code',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: AttendifyPalette.error),
            ),
            const SizedBox(height: 10),
            ...pendingRequests.map(
              (req) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: AttendifyPalette.mutedText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        req.studentName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: _isMutatingSession
                          ? null
                          : () => _resendToStudents(
                              session, [req.studentId]),
                      child: const Text('Resend'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isMutatingSession
                    ? null
                    : () => _resendToStudents(
                          session,
                          pendingRequests.map((r) => r.studentId).toList(),
                        ),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  'Resend to All ${pendingRequests.length} Pending',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LiveSessionConfig {
  final String roomLabel;

  const _LiveSessionConfig({required this.roomLabel});
}
