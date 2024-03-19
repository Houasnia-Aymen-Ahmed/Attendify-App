import 'package:flutter/material.dart';

import '../../services/databases.dart';
import '../../shared/constants.dart';

class AddItemDialog extends StatefulWidget {
  final DatabaseService databaseService;
  final String itemType;
  const AddItemDialog({
    super.key,
    required this.databaseService,
    required this.itemType,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  bool isSaving = false, isDone = false, isError = false, isDisabled = true;
  String? gradeVal, specialityVal, moduleName = "", _newTeacherEmail = "";
  int? numberOfStudents = 0;
  String feedbackMsg = "";

  void submitController() async {
    if (_formKey.currentState!.validate()) {
      try {
        setFeedbackState(true, false, "Saving ${widget.itemType} ...");
        if (widget.itemType == "module") {
          String uid = '${gradeVal}_${specialityVal}_module_';
          await widget.databaseService.updateModuleData(
            uid: uid,
            name: moduleName!,
            isActive: false,
            speciality: specialityVal!,
            grade: gradeVal!,
            numberOfStudents: numberOfStudents!,
            students: {},
            attendanceTable: {},
            isNewModule: true,
          );
        } else {
          await widget.databaseService.addTeacherEmail(_newTeacherEmail!);
        }
        setFeedbackState(false, true, "${widget.itemType} added successfully");
        _formKey.currentState!.reset();
        setState(() {
          gradeVal = specialityVal = null;
          moduleName = _newTeacherEmail = "";
          numberOfStudents = 0;
        });
      } catch (e) {
        setFeedbackState(
          false,
          true,
          "Error saving ${widget.itemType}",
          isError: true,
        );
      }
    }
  }

  void setFeedbackState(
    bool isSaving,
    bool isDone,
    String feedbackMsg, {
    bool isError = false,
  }) {
    setState(() {
      this.isSaving = isSaving;
      this.isDone = isDone;
      this.feedbackMsg = feedbackMsg;
      this.isError = isError;
    });
  }

  Row showFeedback({
    String feedbackMsg = "",
    bool isLoading = false,
    bool isError = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          feedbackMsg,
          style: TextStyle(
            fontSize: 18,
            color: isLoading
                ? Colors.blue[900]
                : isError
                    ? Colors.red
                    : Colors.green,
          ),
        ),
        const SizedBox(width: 25),
        if (isLoading)
          SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: Colors.blue[900],
            ),
          ),
      ],
    );
  }

  Form shownModuleWidgets() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          dropDownBtn(
            hint: "Choose your grade",
            type: "grade",
            gradeVal: gradeVal,
            isExpanded: true,
            filled: true,
            validator: (value) {
              if (gradeVal == null) {
                return "Please select a grade";
              } else {
                return null;
              }
            },
            onChanged: (String? newValue) {
              setState(() {
                isDisabled = false;
                gradeVal = newValue;
                specialityVal = null;
              });
            },
          ),
          dropDownBtn(
            hint: "Choose your speciality",
            type: "speciality",
            isDisabled: isDisabled,
            gradeVal: gradeVal,
            specialityVal: specialityVal,
            isExpanded: true,
            filled: true,
            validator: (value) {
              if (gradeVal == null) {
                return "Please select a speciality";
              } else {
                return null;
              }
            },
            onChanged: isDisabled
                ? null
                : (String? newValue) {
                    setState(
                      () => specialityVal = newValue,
                    );
                  },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              enableSuggestions: true,
              keyboardType: TextInputType.name,
              validator: (value) {
                if ((value?.trim() ?? "").isEmpty) {
                  return "Please enter the module name";
                } else {
                  return null;
                }
              },
              onChanged: (value) {
                setState(() {
                  moduleName = value;
                });
              },
              decoration: textInputDecoration,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              enableSuggestions: true,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return "Please enter the maximum\nnumber of students";
                } else {
                  return null;
                }
              },
              onChanged: (value) {
                setState(() {
                  numberOfStudents = int.tryParse(value) ?? 0;
                });
              },
              decoration: textInputDecoration.copyWith(
                hintText: "Number of students",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Form shownTeacherWidgets() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            setState(() {
              _newTeacherEmail = value;
            });
          },
          validator: (value) {
            if (value!.isEmpty || !value.contains("@")) {
              return "Please enter a valid email";
            } else if (!value.endsWith("@hns-re2sd.dz")) {
              return 'The email should end with "@hns-re2sd.dz"';
            } else {
              return null;
            }
          },
          decoration: textInputDecoration.copyWith(
            hintText: "Teacher's email",
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Add a ${widget.itemType}'),
      contentPadding: const EdgeInsets.all(16.0),
      children: [
        if (widget.itemType == "module")
          shownModuleWidgets()
        else
          shownTeacherWidgets(),
        if (isSaving)
          showFeedback(
              feedbackMsg: "Saving ${widget.itemType} ...", isLoading: true)
        else if (isDone)
          showFeedback(
            feedbackMsg: feedbackMsg,
            isLoading: false,
            isError: isError,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: submitController,
              child: const Text("Add"),
            ),
          ],
        ),
      ],
    );
  }
}
