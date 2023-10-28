import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: SpinKitWaveSpinner(
          curve: Curves.linear,
          trackColor: Colors.blue[300]!,
          waveColor: Colors.blue[200]!,
          color: Colors.blue[100]!,
          size: 150.0,
        ),
      ),
    );
  }
}
