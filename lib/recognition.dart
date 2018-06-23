import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  cameras = await availableCameras();
  runApp(new CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => new _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = new CameraController(cameras[1], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return new Container();
    }

    return new Padding(padding: new EdgeInsets.only(top: 40.0), child: new Scaffold(
        backgroundColor: Color.fromARGB(255, 100, 100, 100),
        body: new Column(children: <Widget>[
      new Padding(padding: new EdgeInsets.all(12.0), child: new Text("Stare at the camera")),
        new Padding(padding: new EdgeInsets.only(left: 45.0, right: 45.0), child: new AspectRatio(aspectRatio: controller.value.aspectRatio,
          child: new CameraPreview(controller))),
    ])));
  }
}