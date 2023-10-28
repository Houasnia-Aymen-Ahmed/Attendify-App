import 'package:attendify/shared/constants.dart';
import 'package:flutter/material.dart';

class ModuleFromList extends StatefulWidget {
  const ModuleFromList({super.key});

  @override
  State<ModuleFromList> createState() => _ModuleFromListState();
}

class _ModuleFromListState extends State<ModuleFromList> {
  String presenceValue = "Absent";
  bool isRoomActive = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[900]?.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            width: 250,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    color: isRoomActive ? Colors.green : Colors.red,
                    size: 12.5,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    isRoomActive ? "Room is active" : "Room is inactive",
                    style: dropDownTextStyle.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[900]?.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton(
              hint: const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  "Choose your module",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              value: null,
              items: [
                DropdownMenuItem(
                  value: "deep_learning",
                  child: Text(
                    "Deep Learning",
                    style: dropDownTextStyle,
                  ),
                ),
                DropdownMenuItem(
                  value: "n_tier_dev",
                  child: Text(
                    "N-Tier Development",
                    style: dropDownTextStyle,
                  ),
                ),
                DropdownMenuItem(
                  value: "android_dev",
                  child: Text(
                    "Android Development",
                    style: dropDownTextStyle,
                  ),
                ),
                DropdownMenuItem(
                  value: "cloud_computing",
                  child: Text(
                    "Cloud Computing",
                    style: dropDownTextStyle,
                  ),
                ),
              ],
              onChanged: (value) {},
              isExpanded: true,
            ),
          ),
        ),
        const Spacer(flex: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue[900]?.withOpacity(0.25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextButton(
              onPressed: (() {}),
              child: Text(
                presenceValue,
                style: dropDownTextStyle.copyWith(fontSize: 25),
              ),
            ),
          ),
        ),
        const Spacer(flex: 5),
        ElevatedButton(
          onPressed: () => setState(() {
            presenceValue = "Present";
            isRoomActive = !isRoomActive;
          }),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[200],
              elevation: 10,
              padding: const EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              )),
          child: const Text(
            "I am Present",
            style: TextStyle(fontSize: 20.0, color: Colors.black),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
