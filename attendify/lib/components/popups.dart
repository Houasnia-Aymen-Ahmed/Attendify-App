import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future showLoadingDialog(
  BuildContext context,
  String content,
) =>
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

Future removeConfirmationDialog(
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

Future showDialogBox(
  BuildContext context,
  String title,
  String content,
  bool isError,
) =>
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

Future showCloseConfirmationDialog(BuildContext context) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text(
          'You have unsaved changes. Do you want to exit without saving?',
        ),
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

void showOverlay(
  BuildContext context,
  OverlayEntry? overlayEntry,
  ValueNotifier<bool> isRoomActive,
) {
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
