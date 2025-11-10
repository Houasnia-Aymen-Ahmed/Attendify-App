import 'package:flutter/material.dart';

class ImageItem extends StatelessWidget {
  final IconData icon;
  const ImageItem({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Icon(
        icon,
        color: Colors.blue[100],
        size: 25,
      ),
    );
  }
}
