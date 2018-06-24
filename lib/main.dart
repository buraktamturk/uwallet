
import 'package:flutter/material.dart';
import 'account.dart';
import 'recognition.dart';
import 'package:camera/camera.dart';

main() async {
  cameras = await availableCameras();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'U-Wallet',
      theme: new ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: new AccountPage(),
    );
  }
}
