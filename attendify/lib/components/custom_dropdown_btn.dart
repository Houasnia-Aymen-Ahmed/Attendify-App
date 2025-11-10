import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../shared/constants.dart';
import '../shared/school_data.dart';
import '../utils/functions.dart';

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

  const CustomDrowdownBtn({
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
  State<CustomDrowdownBtn> createState() => _CustomDrowdownBtnState();
}

class _CustomDrowdownBtnState extends State<CustomDrowdownBtn> {
  @override
  Widget build(BuildContext context) {
    final List<String> items = widget.type == "type"
        ? ["admin", "teacher", "student"]
        : widget.type == "grade"
            ? modulesMap.keys.toList()
            : modulesMap[widget.gradeVal]?.keys.toList() ?? ['item'];

    return DropdownButtonFormField<String>(
      padding: const EdgeInsets.all(8.0),
      elevation: 16,
      isExpanded: widget.isExpanded ?? false,
      dropdownColor: Colors.blue[100],
      borderRadius: BorderRadius.circular(15),
      value: widget.type == "type"
          ? widget.typeVal
          : widget.type == "grade"
              ? widget.gradeVal
              : widget.specialityVal,
      decoration: InputDecoration(
        filled: widget.filled,
        hintText: widget.hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 15,
          color: widget.isDisabled ? Colors.black38 : Colors.blue[900],
        ),
        border: outLineBorder(),
        focusedBorder: outLineBorder(),
        enabledBorder: outLineBorder(),
        alignLabelWithHint: true,
      ),
      style: const TextStyle(backgroundColor: Colors.transparent),
      onChanged: widget.onChanged,
      validator: widget.validator,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            capitalizeFirst(value),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: widget.textColor ?? Colors.black,
            ),
          ),
        );
      }).toList(),
    );
  }
}

