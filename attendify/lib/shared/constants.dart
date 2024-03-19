import 'dart:math';

import 'package:attendify/index.dart';
import 'package:attendify/shared/loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'school_data.dart';

TextStyle txt() {
  return GoogleFonts.poppins(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );
}

final textInputDecoration = InputDecoration(
  hintText: 'Module Name',
  hintStyle: GoogleFonts.poppins(
    fontSize: 15,
    color: Colors.black38,
  ),
  filled: true,
  border: outLineBorder(),
  enabledBorder: outLineBorder(),
  focusedBorder: outLineBorder(),
);

userAccountDrawerHeader({
  required String username,
  required String email,
  required String profileURL,
  bool hasLogout = false,
  void Function()? onLogout,
}) {
  return Stack(
    children: [
      UserAccountsDrawerHeader(
        currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: profileURL,
              placeholder: (context, url) => const Loading(),
              errorWidget: (context, url, error) =>
                  AppImages.defaultProfilePicture,
              fit: BoxFit.contain,
            ),
          ),
        ),
        accountName: Text(
          username,
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        margin: const EdgeInsets.all(8.0),
        accountEmail: Text(
          email,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue[700]!,
              Colors.blue[100]!,
            ],
            tileMode: TileMode.decal,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 0.5,
              blurStyle: BlurStyle.normal,
              offset: Offset(0, 3),
            )
          ],
        ),
        arrowColor: Colors.black,
      ),
      if (hasLogout)
        Positioned(
          top: 16.0,
          right: 16.0,
          child: IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.blue[900]!,
            ),
            onPressed: onLogout,
          ),
        ),
    ],
  );
}

var dropDownTextStyle = GoogleFonts.poppins(
  color: Colors.black,
  fontSize: 15,
  fontWeight: FontWeight.w500,
);

String capitalizeFirst(String input) {
  if (input.length <= 1) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}

String? capitalizeWords(String? input) {
  if (input == null || input.isEmpty) {
    return input;
  }

  List<String> words = input.split(' ');

  for (int i = 0; i < words.length; i++) {
    if (words[i].isNotEmpty) {
      words[i] =
          words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
    }
  }

  return words.join(' ');
}

List<ListTile> drawerList(dynamic user) {
  return [
    ListTile(
      title: Text(
        capitalizeFirst(user?.grade ?? "Grade"),
      ),
      subtitle: const Text("Grade"),
    ),
    ListTile(
      title: Text(
        capitalizeFirst(user?.speciality ?? "Speciality"),
      ),
      subtitle: const Text("Speciality"),
    ),
  ];
}

Padding imageItem(IconData icon) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Icon(
      icon,
      color: Colors.blue[100],
      size: 35,
    ),
  );
}

OutlineInputBorder outLineBorder() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: Colors.blue[900]!,
        width: 1.0,
        style: BorderStyle.solid,
      ),
    );

DropdownButtonFormField<String> dropDownBtn({
  required hint,
  required type,
  bool isDisabled = false,
  bool? isExpanded,
  bool? filled = false,
  String? typeVal,
  String? gradeVal,
  String? specialityVal,
  Color? textColor,
  void Function(String?)? onChanged,
  String? Function(String?)? validator,
}) {
  dynamic items = type == "type"
      ? ["admin", "teacher", "student"]
      : type == "grade"
          ? modulesMap.keys.toList()
          : modulesMap[gradeVal]?.keys.toList() ?? ['item'];

  return DropdownButtonFormField<String>(
    padding: const EdgeInsets.all(8.0),
    elevation: 16,
    isExpanded: isExpanded ?? false,
    dropdownColor: Colors.blue[100],
    borderRadius: BorderRadius.circular(15),
    value: type == "type"
        ? typeVal
        : type == "grade"
            ? gradeVal
            : specialityVal,
    decoration: InputDecoration(
      filled: filled,
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 15,
        color: isDisabled ? Colors.black38 : Colors.blue[900],
      ),
      border: outLineBorder(),
      focusedBorder: outLineBorder(),
      enabledBorder: outLineBorder(),
      alignLabelWithHint: true,
    ),
    style: const TextStyle(backgroundColor: Colors.transparent),
    onChanged: onChanged,
    validator: validator,
    items: items.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          capitalizeFirst(value),
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.black,
          ),
        ),
      );
    }).toList(),
  );
}

void showLoadingDialog(
  BuildContext context,
  String content,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(content),
          ],
        ),
      );
    },
  );
}

void removeConfirmationDialog(
  BuildContext context,
  String itemType,
  VoidCallback removeItem,
) =>
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete $itemType"),
          content: Text("Are you sure you want to delete this $itemType"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (itemType == "teacher") {
                  removeItem;
                } else {
                  removeItem;
                }
                Navigator.pop(context, true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

void showDialogBox(
  BuildContext context,
  String title,
  String content,
  bool isError,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          color: isError ? Colors.red : Colors.green,
        ),
      ),
      content: Text(
        content,
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            if (isError) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    ),
  );
}

Future<void> showCloseConfirmationDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text(
            'You have unsaved changes. Do you want to exit without saving?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Back'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Exit Anyway'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void showOverlay(BuildContext context, OverlayEntry? overlayEntry,
    ValueNotifier<bool> isRoomActive) {
  Size screenSize = MediaQuery.of(context).size;
  double screenSizeWidth = screenSize.width,
      screenSizeHeight = screenSize.height;
  Size cardSize = Size(screenSizeWidth * 0.85, screenSizeHeight * 0.5);
  dynamic cardPosition = [
    screenSizeWidth / 2 - cardSize.width / 2,
    screenSizeHeight / 2 - cardSize.height / 2,
  ];

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: cardPosition[1],
      left: cardPosition[0],
      child: SizedBox(
        width: cardSize.width,
        height: cardSize.height,
        child: Card(
          color: Colors.white,
          elevation: 10,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () {
                    overlayEntry!.remove();
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
              Positioned(
                top: 50,
                left: 50,
                child: ValueListenableBuilder(
                  valueListenable: isRoomActive,
                  builder: (BuildContext context, bool value, Widget? child) {
                    return Row(
                      children: <Widget>[
                        const Text(
                          "Enable module presence",
                          style: TextStyle(fontSize: 17.5),
                        ),
                        Switch(
                          value: value,
                          onChanged: (val) {
                            isRoomActive.value = val;
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Overlay.of(context).insert(overlayEntry);
}

List<Widget> dashboardDrawerList({
  required BuildContext context,
  required int selectedIndex,
  required Function(int) onTap,
  Function(int)? onLongTap,
}) {
  return [
    dashboardDrawerListTile(
      'Modules',
      'Add new modules',
      FontAwesomeIcons.bookOpenReader,
      selectedIndex == 0,
      onTap: () => onTap(0),
    ),
    dashboardDrawerListTile(
      'Teachers',
      'Add new teachers',
      FontAwesomeIcons.personChalkboard,
      selectedIndex == 1,
      onTap: () => onTap(1),
    ),
    /* dashboardDrawerListTile(
      'Students',
      'Add new students',
      FontAwesomeIcons.graduationCap,
      selectedIndex == 2,
      onTap: () {
        onTap(2);
        //Navigator.pushNamed(context, "routeName");
      },
    ), */
    dashboardDrawerListTile(
      'Settings',
      'Open settings',
      FontAwesomeIcons.gears,
      selectedIndex == 2,
      onTap: () => onTap(2),
    ),
  ];
}

Widget dashboardDrawerListTile(
  String title,
  String subtitle,
  IconData icon,
  bool selected, {
  VoidCallback? onTap,
  VoidCallback? onLongTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 8.0,
      vertical: 6.0,
    ),
    child: ListTile(
      horizontalTitleGap: 20.0,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 8.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      splashColor: Colors.blue[700],
      tileColor: selected ? Colors.blue[700] : Colors.blue[300],
      leading: Icon(
        icon,
        color: selected ? Colors.white : Colors.blue[900],
        size: 30,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 19,
          color: selected ? Colors.white : Colors.blue[900],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: selected ? Colors.white54 : Colors.blueGrey,
        ),
      ),
      onTap: onTap,
      onLongPress: onLongTap,
    ),
  );
}

final Random random = Random(42);
final List<String> names = [
  'Houasnia',
  'Aymen',
  'Ahmed',
  'Abdelouadoud',
  'Khalfi',
  'Houach',
  'Mohammed',
  'Difallah',
  'Fairouz',
  'Chemmami',
  'Abderzak'
];
final List<String> students = List.generate(
  27,
  (index) {
    final randomNames = List.from(names)..shuffle(random);
    return '${randomNames[0]} ${randomNames[1]}';
  },
);
final Map<String, double> studentUidToRandomNumber = Map.fromEntries(
  students.map(
    (student) => MapEntry(
      'uid',
      random.nextInt(21).toDouble(),
    ),
  ),
);

Future<bool?> infoTost(String msg) async {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.CENTER,
    fontSize: 20.0,
    backgroundColor: Colors.blue[700],
    textColor: Colors.white,
  );
  return null;
}

Widget drawerFooter() => Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          "Houasnia-Aymen-Ahmed\n© 2023-${DateTime.now().year} All rights reserved",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
