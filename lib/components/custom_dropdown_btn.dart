import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:attendify/shared/constants.dart';
import 'package:attendify/shared/school_data.dart';
import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/utils/functions.dart';

class CustomDropdownBtn extends StatefulWidget {
  final String hint;
  final String type;
  final bool isDisabled;
  final bool? filled;
  final bool? isExpanded;
  final String? typeVal;
  final String? gradeVal;
  final String? specialityVal;
  final Color? textColor;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;

  const CustomDropdownBtn({
    super.key,
    required this.hint,
    required this.type,
    this.isDisabled = false,
    this.filled = false,
    this.isExpanded,
    this.typeVal,
    this.gradeVal,
    this.specialityVal,
    this.textColor,
    this.onChanged,
    this.validator,
  });

  @override
  State<CustomDropdownBtn> createState() => _CustomDropdownBtnState();
}

class _CustomDropdownBtnState extends State<CustomDropdownBtn> {
  @override
  Widget build(BuildContext context) {
    final List<String> items = widget.type == 'type'
        ? ['admin', 'teacher', 'student']
        : widget.type == 'grade'
            ? modulesMap.keys.toList()
            : modulesMap[widget.gradeVal]?.keys.toList() ?? ['item'];

    return DropdownButtonFormField<String>(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      elevation: 8,
      isExpanded: widget.isExpanded ?? false,
      dropdownColor: AttendifyPalette.surface,
      borderRadius: BorderRadius.circular(18),
      initialValue: widget.type == 'type'
          ? widget.typeVal
          : widget.type == 'grade'
              ? widget.gradeVal
              : widget.specialityVal,
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.isDisabled
            ? AttendifyPalette.surfaceStrong
            : AttendifyPalette.surfaceMuted,
        hintText: widget.hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: widget.isDisabled
              ? AttendifyPalette.mutedText
              : AttendifyPalette.primary,
        ),
        border: outLineBorder(),
        focusedBorder: outLineBorder(),
        enabledBorder: outLineBorder(),
        alignLabelWithHint: true,
      ),
      style: const TextStyle(backgroundColor: Colors.transparent),
      onChanged: widget.isDisabled ? null : widget.onChanged,
      validator: widget.validator,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            capitalizeFirst(value),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: widget.textColor ?? AttendifyPalette.text,
            ),
          ),
        );
      }).toList(),
    );
  }
}
