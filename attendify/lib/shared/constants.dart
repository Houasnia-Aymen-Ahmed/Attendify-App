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

final textDisabled = Text(
  "Your friend's Message",
  style: txt().copyWith(fontSize: 25.0, color: Colors.grey),
  textAlign: TextAlign.center,
);

userAccountDrawerHeader({String? username, String? email}) {
  return UserAccountsDrawerHeader(
    accountName: Text(
      username ?? "Houasnia Ahmed Aymen",
      style: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
    accountEmail: Text(
      email ?? "aymenaymen2056@gmail.com",
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
        ]),
    arrowColor: Colors.black,
  );
}

var dropDownTextStyle = GoogleFonts.poppins(
  color: Colors.black,
  fontSize: 15,
  fontWeight: FontWeight.w500,
);

String capitalizeFirst(String? input) {
  if (input == null) {
    return "text";
  }

  if (input.length <= 1) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}

List<String> modules = [
  "Advanced AI (Deep Learning)",
  "Virualization & Industrial Control on the Cloud",
  "Mobile Applications & HMI under Android",
  "Home Automation for Renewable Energy",
  "N-tier Development",
  "Smart Grids",
  "Industrial Metrology",
  "Workshop: Entrepreneurship & Startup Establishment",
  "Academic Ethics",
];

const modulesMap = {
  "5th": {
    "iriia": [
      "Advanced AI (Deep Learning)",
      "Virualization & Industrial Control on the Cloud",
      "Mobile Applications & HMI under Android",
      "Home Automation for Renewable Energy",
      "N-tier Development",
      "Smart Grids",
      "Industrial Metrology",
      "Workshop: Entrepreneurship & Startup Establishment",
      "Academic Ethics",
    ],
    "er": [
      "5th er modules 1",
      "5th er modules 2",
      "5th er modules 3",
      "5th er modules 4",
      "5th er modules 5",
      "5th er modules 6",
      "5th er modules 7",
      "5th er modules 8",
      "5th er modules 9",
    ],
    "micro": [""],
    "ge": [""],
    "gh": [""],
  },
  "4th": {
    "iriia": [
      "4th iriia modules 1",
      "4th iriia modules 2",
      "4th iriia modules 3",
      "4th iriia modules 4",
      "4th iriia modules 5",
      "4th iriia modules 6",
      "4th iriia modules 7",
      "4th iriia modules 8",
      "4th iriia modules 9",
    ],
    "er": [
      "4th er modules 1",
      "4th er modules 2",
      "4th er modules 3",
      "4th er modules 4",
      "4th er modules 5",
      "4th er modules 6",
      "4th er modules 7",
      "4th er modules 8",
      "4th er modules 9",
    ],
    "micro": [
      "4th micro modules 1",
      "4th micro modules 2",
      "4th micro modules 3",
      "4th micro modules 4",
      "4th micro modules 5",
      "4th micro modules 6",
      "4th micro modules 7",
      "4th micro modules 8",
      "4th micro modules 9",
    ],
    "ge": [
      "4th ge modules 1",
      "4th ge modules 2",
      "4th ge modules 3",
      "4th ge modules 4",
      "4th ge modules 5",
      "4th ge modules 6",
      "4th ge modules 7",
      "4th ge modules 8",
      "4th ge modules 9",
    ],
    "gh": [
      "4th gh modules 1",
      "4th gh modules 2",
      "4th gh modules 3",
      "4th gh modules 4",
      "4th gh modules 5",
      "4th gh modules 6",
      "4th gh modules 7",
      "4th gh modules 8",
      "4th gh modules 9",
    ],
  },
  "3rd": {
    "iriia": [
      "3rd iriia modules 1",
      "3rd iriia modules 2",
      "3rd iriia modules 3",
      "3rd iriia modules 4",
      "3rd iriia modules 5",
      "3rd iriia modules 6",
      "3rd iriia modules 7",
      "3rd iriia modules 8",
      "3rd iriia modules 9",
    ],
    "er": [
      "3rd er modules 1",
      "3rd er modules 2",
      "3rd er modules 3",
      "3rd er modules 4",
      "3rd er modules 5",
      "3rd er modules 6",
      "3rd er modules 7",
      "3rd er modules 8",
      "3rd er modules 9",
    ],
    "micro": [
      "3rd micro modules 1",
      "3rd micro modules 2",
      "3rd micro modules 3",
      "3rd micro modules 4",
      "3rd micro modules 5",
      "3rd micro modules 6",
      "3rd micro modules 7",
      "3rd micro modules 8",
      "3rd micro modules 9",
    ],
    "ge": [
      "3rd ge modules 1",
      "3rd ge modules 2",
      "3rd ge modules 3",
      "3rd ge modules 4",
      "3rd ge modules 5",
      "3rd ge modules 6",
      "3rd ge modules 7",
      "3rd ge modules 8",
      "3rd ge modules 9",
    ],
    "gh": [
      "3rd gh modules 1",
      "3rd gh modules 2",
      "3rd gh modules 3",
      "3rd gh modules 4",
      "3rd gh modules 5",
      "3rd gh modules 6",
      "3rd gh modules 7",
      "3rd gh modules 8",
      "3rd gh modules 9",
    ],
  }
};

const Map<String, List<String>> specialities = {
  '3rd': ['er', 'ge', 'gh', 'iriia', 'micro'],
  '4th': ['er', 'ge', 'gh', 'iriia', 'micro'],
  '5th': ['er', 'ge', 'gh', 'iriia', 'micro'],
};

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
