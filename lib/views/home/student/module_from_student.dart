import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/live_session.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/models/session_check_in.dart';
import 'package:attendify/models/session_code.dart';
import 'package:attendify/services/databases.dart';
import 'package:attendify/services/providers.dart';
import 'package:attendify/shared/error_pages.dart';
import 'package:attendify/shared/loading.dart';
import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/theme/attendify_ui.dart';
import 'package:attendify/utils/module_metrics.dart';

// Tracks where the student is in the check-in flow
enum _CheckInPhase {
  idle,         // "Mark Present" button visible
  showingCode,  // code flashing on screen for 6 seconds
  enteringCode, // student types the code they just saw
  submitting,   // waiting for Firestore write
  requesting,   // waiting for requestCode write
}

class ModuleViewFromStudent extends ConsumerStatefulWidget {
  final Module module;
  final Student student;
  final DatabaseService databaseService;

  const ModuleViewFromStudent({
    super.key,
    required this.module,
    required this.student,
    required this.databaseService,
  });

  @override
  ConsumerState<ModuleViewFromStudent> createState() =>
      _ModuleViewFromStudentState();
}

class _ModuleViewFromStudentState
    extends ConsumerState<ModuleViewFromStudent> {
  late final String date;

  _CheckInPhase _phase = _CheckInPhase.idle;
  String? _displayCode;
  int _displaySecondsLeft = SessionCode.displaySeconds;

  final _codeController = TextEditingController();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    date = todayAttendanceKey();
    // Single ticker drives both the 6-second code display and
    // the remaining-time countdown in the enter-code phase.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_phase == _CheckInPhase.showingCode) {
          _displaySecondsLeft--;
          if (_displaySecondsLeft <= 0) {
            _phase = _CheckInPhase.enteringCode;
            _displaySecondsLeft = 0;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _onMarkPresent(SessionCode sessionCode) {
    _codeController.clear();
    setState(() {
      _phase = _CheckInPhase.showingCode;
      _displayCode = sessionCode.code;
      _displaySecondsLeft = SessionCode.displaySeconds;
    });
  }

  Future<void> _submitCode(String sessionId) async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the full 6-digit code.')),
      );
      return;
    }

    setState(() => _phase = _CheckInPhase.submitting);
    try {
      await ref.read(sessionServiceProvider).submitCheckIn(sessionId, code);
      if (!mounted) return;
      _codeController.clear();
      setState(() => _phase = _CheckInPhase.idle);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance confirmed successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _phase = _CheckInPhase.idle);
      final message =
          error is FirebaseException && error.code == 'permission-denied'
              ? 'Incorrect or expired code. Request a new one from your teacher.'
              : error.toString();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _requestNewCode(String sessionId) async {
    setState(() => _phase = _CheckInPhase.requesting);
    try {
      await ref.read(sessionServiceProvider).requestCode(
            sessionId,
            widget.student.uid,
            widget.student.userName,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Request sent. Your teacher will resend your code shortly.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _phase = _CheckInPhase.idle);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Module>(
      stream: widget.databaseService.getModuleStream(widget.module.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (snapshot.hasError) {
          return ErrorPages(
            title: 'Server Error',
            message: snapshot.error.toString(),
          );
        } else if (!snapshot.hasData) {
          return const ErrorPages(
            title: 'Error 404: Not Found',
            message: 'No module data available for student',
          );
        }

        final module = snapshot.data!;
        final attendanceDates = sortedAttendanceDates(module);
        final totalSessions = module.attendanceTable.length;
        final attendanceRate = studentAttendancePercentage(
          module,
          widget.student.uid,
        ).toStringAsFixed(0);

        final activeSessionAsync =
            ref.watch(activeSessionProvider(module.uid));

        return activeSessionAsync.when(
          data: (activeSession) {
            // Reset phase if session closed while student was mid-flow
            if (activeSession == null &&
                _phase != _CheckInPhase.idle) {
              Future.microtask(() {
                if (mounted) setState(() => _phase = _CheckInPhase.idle);
              });
            }

            final checkInAsync = activeSession == null
                ? const AsyncData<SessionCheckIn?>(null)
                : ref.watch(studentSessionCheckInProvider(
                    (
                      sessionId: activeSession.id,
                      studentId: widget.student.uid,
                    ),
                  ));

            final sessionCodeAsync = activeSession == null
                ? const AsyncData<SessionCode?>(null)
                : ref.watch(studentCodeProvider(
                    (
                      sessionId: activeSession.id,
                      studentId: widget.student.uid,
                    ),
                  ));

            return checkInAsync.when(
              data: (currentCheckIn) {
                final hasCheckedIn = currentCheckIn != null;
                final sessionCode = sessionCodeAsync.asData?.value;

                // Auto-reset to idle once check-in confirmed
                if (hasCheckedIn && _phase != _CheckInPhase.idle) {
                  Future.microtask(() {
                    if (mounted) setState(() => _phase = _CheckInPhase.idle);
                  });
                }

                return Scaffold(
                  body: AttendifyScreen(
                    title: module.name,
                    subtitle:
                        '${module.grade} year • ${module.speciality}',
                    leading: IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AttendifyPalette.primary,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Check-in card ──────────────────────────────────
                        AttendifySurface(
                          color: AttendifyPalette.primary,
                          child: _buildCheckInContent(
                            context,
                            activeSession,
                            hasCheckedIn,
                            sessionCode,
                          ),
                        ),

                        const SizedBox(height: AttendifySpacing.lg),

                        // ── Metric cards ───────────────────────────────────
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth > 560;
                            final itemWidth = wide
                                ? (constraints.maxWidth - AttendifySpacing.md) / 2
                                : constraints.maxWidth;
                            return Wrap(
                              spacing: AttendifySpacing.md,
                              runSpacing: AttendifySpacing.md,
                              children: [
                                SizedBox(
                                  width: itemWidth,
                                  child: AttendifyMetricCard(
                                    label: 'Attendance rate',
                                    value: '$attendanceRate%',
                                    helper:
                                        'Across $totalSessions synced sessions',
                                    icon: Icons.trending_up_rounded,
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: AttendifyMetricCard(
                                    label: 'Current status',
                                    value: activeSession == null
                                        ? 'Closed'
                                        : 'Live',
                                    helper: hasCheckedIn
                                        ? 'Checked in for the live session'
                                        : activeSession == null
                                            ? 'Awaiting the teacher session'
                                            : 'Waiting for your check-in',
                                    icon: activeSession == null
                                        ? Icons.schedule_rounded
                                        : Icons.radio_button_checked_rounded,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: AttendifySpacing.xl),

                        // ── Attendance history ─────────────────────────────
                        Text(
                          'Attendance history',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AttendifySpacing.sm),
                        Text(
                          'Your synced session history appears below after each live session closes.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AttendifyPalette.mutedText),
                        ),
                        const SizedBox(height: AttendifySpacing.lg),

                        if (attendanceDates.isEmpty)
                          const AttendifyEmptyState(
                            title: 'No sessions recorded yet',
                            message:
                                'Your attendance history will appear here once '
                                'the first class session is completed.',
                          )
                        else
                          ...attendanceDates.map((entryDate) {
                            final isPresent = studentCheckedInForDate(
                              module,
                              widget.student.uid,
                              entryDate,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AttendifySpacing.md),
                              child: AttendifySurface(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 68,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AttendifySpacing.md,
                                        horizontal: AttendifySpacing.sm,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: AttendifyPalette.surfaceMuted,
                                        borderRadius:
                                            AttendifyRadius.mdAll,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            entryDate.substring(0, 2),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          const SizedBox(height: AttendifySpacing.xs),
                                          Text(
                                            entryDate.substring(3),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AttendifySpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isPresent ? 'Present' : 'Absent',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          const SizedBox(height: AttendifySpacing.xs),
                                          Text(
                                            isPresent
                                                ? 'Attendance confirmed successfully for this session.'
                                                : 'No attendance confirmation was recorded for this date.',
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
                                    const SizedBox(width: AttendifySpacing.md),
                                    AttendifyStatusChip(
                                      label: isPresent ? 'Present' : 'Absent',
                                      color: isPresent
                                          ? AttendifyPalette.secondary
                                          : AttendifyPalette.error,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Loading(),
              error: (e, _) => ErrorPages(
                title: 'Check-in Error',
                message: e.toString(),
              ),
            );
          },
          loading: () => const Loading(),
          error: (e, _) => ErrorPages(
            title: 'Live Session Error',
            message: e.toString(),
          ),
        );
      },
    );
  }

  // ── Check-in card content (state machine) ──────────────────────────────────

  Widget _buildCheckInContent(
    BuildContext context,
    LiveSession? activeSession,
    bool hasCheckedIn,
    SessionCode? sessionCode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIVE CHECK-IN',
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: AttendifySpacing.md),

        // ── Heading ────────────────────────────────────────────────────────
        Text(
          activeSession == null
              ? 'Session not active'
              : hasCheckedIn
                  ? 'Attendance confirmed'
                  : 'Session open now',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: AttendifySpacing.sm),
        Text(
          activeSession == null
              ? 'The teacher has not started a live session for this module yet.'
              : hasCheckedIn
                  ? 'Your attendance has been recorded for this session.'
                  : 'Room ${activeSession.roomLabel} — listen for your teacher\'s instruction.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: AttendifySpacing.lg),

        // ── Action area ────────────────────────────────────────────────────
        if (activeSession == null)
          const AttendifyStatusChip(
            label: 'Waiting for teacher session',
            color: Colors.white,
          )
        else if (hasCheckedIn)
          const AttendifyStatusChip(
            label: 'Attendance confirmed ✓',
            color: AttendifyPalette.secondary,
          )
        else
          _buildActiveFlow(context, activeSession, sessionCode),
      ],
    );
  }

  Widget _buildActiveFlow(
    BuildContext context,
    LiveSession session,
    SessionCode? sessionCode,
  ) {
    switch (_phase) {
      case _CheckInPhase.idle:
        return _buildIdlePhase(context, session, sessionCode);

      case _CheckInPhase.showingCode:
        return _buildShowingCodePhase(context);

      case _CheckInPhase.enteringCode:
        return _buildEnterCodePhase(context, session, sessionCode);

      case _CheckInPhase.submitting:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );

      case _CheckInPhase.requesting:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
    }
  }

  // Idle: show "Mark Present" if code available, else waiting message
  Widget _buildIdlePhase(
    BuildContext context,
    LiveSession session,
    SessionCode? sessionCode,
  ) {
    final codeAvailable =
        sessionCode != null && !sessionCode.isExpired;
    final codeExpired =
        sessionCode != null && sessionCode.isExpired;

    if (codeExpired) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AttendifyStatusChip(
            label: 'Code expired',
            color: AttendifyPalette.error,
          ),
          const SizedBox(height: AttendifySpacing.lg),
          Text(
            'Your attendance code has expired. Tap below to ask your teacher for a new one.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AttendifySpacing.lg),
          AttendifyPrimaryButton(
            label: 'Request New Code',
            icon: Icons.refresh_rounded,
            onPressed: () => _requestNewCode(session.id),
          ),
        ],
      );
    }

    if (!codeAvailable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AttendifyStatusChip(
            label: 'Waiting for teacher',
            color: Colors.white,
          ),
          const SizedBox(height: AttendifySpacing.sm),
          Text(
            'Your teacher hasn\'t sent codes yet. Once they do, '
            'tap "Mark Present" to confirm your attendance.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AttendifySpacing.lg),
          const AttendifyPrimaryButton(
            label: 'Mark Present',
            icon: Icons.how_to_reg_rounded,
            onPressed: null, // disabled until code arrives
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AttendifyStatusChip(
          label: 'Code ready — ${sessionCode.secondsRemaining}s remaining',
          color: AttendifyPalette.secondary,
        ),
        const SizedBox(height: AttendifySpacing.lg),
        Text(
          'Tap "Mark Present". Your unique code will be shown for '
          '${SessionCode.displaySeconds} seconds — memorize it, then type it in.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: AttendifySpacing.lg),
        AttendifyPrimaryButton(
          label: 'Mark Present',
          icon: Icons.how_to_reg_rounded,
          onPressed: () => _onMarkPresent(sessionCode),
        ),
      ],
    );
  }

  // Show code as large digits for 6 seconds
  Widget _buildShowingCodePhase(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your code — memorize it now ($_displaySecondsLeft s)',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: AttendifySpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (_displayCode ?? '------').split('').map((digit) {
            return Container(
              width: 42,
              height: 54,
              margin: const EdgeInsets.symmetric(horizontal: AttendifySpacing.xs),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white30),
              ),
              child: Center(
                child: Text(
                  digit,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AttendifySpacing.lg),
        Text(
          'The input field will appear automatically.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.white54),
        ),
      ],
    );
  }

  // Enter code phase — text field + submit
  Widget _buildEnterCodePhase(
    BuildContext context,
    LiveSession session,
    SessionCode? sessionCode,
  ) {
    final secondsLeft = sessionCode?.secondsRemaining ?? 0;
    final stillValid = secondsLeft > 0;

    if (!stillValid) {
      // Code expired while student was reading it — switch to expired view
      Future.microtask(
        () { if (mounted) setState(() => _phase = _CheckInPhase.idle); },
      );
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type the code you just saw — $secondsLeft seconds left',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: AttendifySpacing.lg),
        TextField(
          controller: _codeController,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: '------',
            hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 8),
            filled: true,
            fillColor: Colors.white12,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white30),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white30),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.white70, width: 2),
            ),
          ),
          onSubmitted: (_) => _submitCode(session.id),
        ),
        const SizedBox(height: AttendifySpacing.lg),
        AttendifyPrimaryButton(
          label: 'Confirm Attendance',
          icon: Icons.check_rounded,
          onPressed: () => _submitCode(session.id),
        ),
      ],
    );
  }
}
