import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const textInputDecoation = InputDecoration(
  contentPadding: EdgeInsets.fromLTRB(27, 20, 27, 20),
  hintText: "Email",
  hintStyle: TextStyle(
    color: Colors.white54,
  ),
  fillColor: Colors.transparent,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.white38,
      width: 2,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.white,
      width: 2,
    ),
  ),
);

txt() {
  return GoogleFonts.poppins(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );
}

final elevatedBtnStyle = ElevatedButton.styleFrom(
  shadowColor: Colors.white.withOpacity(0.1),
  backgroundColor: Colors.transparent,
  elevation: 1,
  fixedSize: const Size(100, 50),
);

userAccountDrawerHeader({required String username, required String email}) {
  return UserAccountsDrawerHeader(
    accountName: Text(
      username,
      style: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
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
      gradient: LinearGradient(colors: [
        Colors.blue[900]!,
        Colors.blue[100]!,
      ]),
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

DropdownButton<String> dropDownBtn({
  required hint,
  required type,
  bool isDisabled = false,
  String? gradeVal,
  String? specialityVal,
  void Function(String?)? onChanged,
}) {
  dynamic items = type == "grade"
      ? modulesMap.keys.toList()
      : modulesMap[gradeVal]?.keys.toList() ?? ['item'];

  return DropdownButton<String>(
    padding: const EdgeInsets.all(8.0),
    elevation: 16,
    dropdownColor: Colors.blue[100],
    borderRadius: BorderRadius.circular(20),
    value: type == "grade" ? gradeVal : specialityVal,
    hint: Text(
      hint,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: isDisabled ? Colors.blueGrey : Colors.blue[900],
      ),
    ),
    style: const TextStyle(
      color: Colors.black,
      backgroundColor: Colors.transparent,
    ),
    underline: Container(
      height: 2,
      color: isDisabled ? Colors.blueGrey : Colors.blue[900],
    ),
    onChanged: onChanged,
    items: items.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          capitalizeFirst(value),
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }).toList(),
  );
}

const modulesMap = {
  "formations": {
    "python": [
      "session_01",
      "session_02",
      "session_03",
      "session_04",
      "session_05",
      "session_06",
      "session_07",
      "session_08",
      "session_09",
      "session_10",
    ]
  },
  "Sem 9": {
    "iriia": [
      "Academic Ethics and Deontology",
      "Advanced Artificial Intelligence (Deep Learning)",
      "Home Automation for Renewable Energy",
      "Industrial Metrology",
      "Mobile Applications & HMI under Android",
      "N-tier Development",
      "Smart Grids",
      "Virualization & Industrial Control on the Cloud",
      "Workshop: Entrepreneurship & Startup Establishment",
    ],
    "er": [
      "Electrical Energy Quality",
      "Energy Audit",
      "Energy Transition and Legislation &amp; Regulation",
      "Innovation, Intellectual Property and Ethics",
      "Microgrids and Smart Grids",
      "Monitoring, Diagnosis and Maintenance of Energy Systems",
      "Project Management and Life Cycle Analysis",
      "Techno-economic Optimisation of Hybrid Systems",
      "Technological Trends",
      "Workshop 1: Entrepreneurship and Startup Establishment",
      "Workshop 2 : Engineering Project Study",
    ],
    "micro": [""],
    "ge": [""],
    "gh": [""],
  },
  "Sem 7": {
    "iriia": [
      "Human-Machine Interaction for Industry",
      "Industrial Local Area Networks",
      "Industrial Programmable Logic Controllers",
      "Machine Learning",
      "Programming networks and web services",
      "µ-Controllers 2",
    ],
    "er": [
      "Building Energy",
      "Design and Optimisation of PV Power Plants",
      "Design and Optimization of Wind Power Plants",
      "Energy Storage",
      "Green hydrogen supply chains",
      "Modelling and Optimisation of Energy Systems",
    ],
    "micro": [
      "Integrated circuit design 1",
      "Photovoltaic devices",
      "Electronic functions 1",
      "µ-Controllers 2",
      "Legal metrology",
      "Simulation tools",
      "Digital signal processing",
    ],
    "ge": [
      "Basic Linear Control Systems",
      "Electronique Analogique",
      "Electromagnetism and waves",
      "Fundamental Electrotechnics",
      "Mathematics for engineers",
      "Sensors and measuring instruments",
      "Signal processing",
    ],
    "gh": [""],
  },
  "Sem 5": {
    "iriia": [
      "Computer Networks 1",
      "Computer Architecture",
      "Operating systems",
      "Renewable Energy &amp; Energy Efficiency",
      "Sensors and Actuators",
    ],
    "er": [
      "Electrical Machines",
      "Fluid mechanics",
      "Renewable Energy Resources",
      "Scientific computing and programming",
      "Applied Thermodynamics",
      "Workshop 1",
    ],
    "micro": [
      "Circuit theory",
      "Combinational and Sequential Logic",
      "Maths Complex analysis",
      "Renewable Energy",
      "Semiconductor Physics 1",
      "Signal Theory",
      "3rd micro modules 7",
      "3rd micro modules 8",
      "3rd micro modules 9",
    ],
    "ge": [
      "Basic Linear Control Systems",
      "Electronique Analogique",
      "Electromagnetism and waves",
      "Fundamental Electrotechnics",
      "Mathematics for engineers",
      "Sensors and measuring instruments",
      "Signal processing",
    ],
    "gh": [""],
  }
};

const Map<String, List<String>> specialities = {
  /* 'Sem 1': ['er', 'ge', 'gh', 'iriia', 'micro'],
  'Sem 2': ['er', 'ge', 'gh', 'iriia', 'micro'],
  'Sem 3': ['er', 'ge', 'gh', 'iriia', 'micro'],
  'Sem 4': ['er', 'ge', 'gh', 'iriia', 'micro'], */
  'Sem 5': ['er', 'ge', 'gh', 'iriia', 'micro'],
  //'Sem 6': ['er', 'ge', 'gh', 'iriia', 'micro'],
  'Sem 7': ['er', 'ge', 'gh', 'iriia', 'micro'],
  //'Sem 8': ['er', 'ge', 'gh', 'iriia', 'micro'],
  'Sem 9': ['er', 'ge', 'gh', 'iriia', 'micro'],
  //'Sem 10': ['er', 'ge', 'gh', 'iriia', 'micro'],
  'formations': ['python'],
};

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
