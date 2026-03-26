import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/custom_dropdown_btn.dart';
import '../../theme/attendify_theme.dart';
import '../../theme/attendify_ui.dart';
import 'register_controller.dart';

class Register extends ConsumerStatefulWidget {
  final VoidCallback toggleView;

  const Register({
    super.key,
    required this.toggleView,
  });

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register> {
  String _validationError = "";
  bool _isDisabled = true;
  String _typeVal = "student";
  String? _gradeVal, _specialityVal;

  Future<void> buttonController() async {
    final registerController = ref.read(registerControllerProvider.notifier);

    if (_typeVal == "student" && (_gradeVal == null || _specialityVal == null)) {
      setState(() {
        _validationError =
            "Please make sure to select both a grade and a speciality.";
      });
      return;
    }

    setState(() {
      _validationError = "";
    });

    await registerController.signUp(_typeVal, _gradeVal, _specialityVal);
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerControllerProvider);
    final registerController = ref.read(registerControllerProvider.notifier);
    final errorText = _validationError.isNotEmpty
        ? _validationError
        : registerState == RegisterState.error
            ? registerController.error ?? ""
            : "";

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: AttendifySurface(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AttendifySectionHeader(
                eyebrow: "Create access",
                title: "Prepare your account",
                subtitle:
                    "Pick your role, complete the student details if needed, then continue with your HNS Google account.",
              ),
              const SizedBox(height: 22),
              Text(
                "Role",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ["student", "teacher", "admin"].map((role) {
                  final isSelected = _typeVal == role;
                  return ChoiceChip(
                    label: Text(role[0].toUpperCase() + role.substring(1)),
                    selected: isSelected,
                    onSelected: (_) {
                      registerController.reset();
                      setState(() {
                        _typeVal = role;
                        _validationError = "";
                        _gradeVal = null;
                        _specialityVal = null;
                        _isDisabled = true;
                      });
                    },
                  );
                }).toList(),
              ),
              if (_typeVal == "student") ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdownBtn(
                        hint: "Choose grade",
                        type: "grade",
                        isDisabled: false,
                        gradeVal: _gradeVal,
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          registerController.reset();
                          setState(() {
                            _isDisabled = false;
                            _validationError = "";
                            _gradeVal = newValue;
                            _specialityVal = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomDropdownBtn(
                        hint: "Choose speciality",
                        type: "speciality",
                        isDisabled: _isDisabled,
                        gradeVal: _gradeVal,
                        specialityVal: _specialityVal,
                        isExpanded: true,
                        onChanged: _isDisabled
                            ? null
                            : (String? newValue) {
                                registerController.reset();
                                setState(() {
                                  _validationError = "";
                                  _specialityVal = newValue;
                                });
                              },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AttendifyPalette.surfaceMuted,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _typeVal == "student"
                      ? "Student registration links your Google account to your grade, speciality, and modules."
                      : "Teacher and admin registration still require approved institution emails. Attendify validates that after Google sign-in.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 20),
              AttendifyPrimaryButton(
                label: "Continue with Google",
                icon: Icons.arrow_forward_rounded,
                isLoading: registerState == RegisterState.loading,
                onPressed: buttonController,
              ),
              if (errorText.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AttendifyPalette.error.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    errorText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AttendifyPalette.error,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already registered?",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      registerController.reset();
                      widget.toggleView();
                    },
                    child: const Text("Sign in"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
