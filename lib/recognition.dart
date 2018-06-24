import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;

List<CameraDescription> cameras;

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => new _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;
  String location;

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

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  Future<String> takePicture() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath, );
    } on CameraException catch (e) {
      return null;
    }

    return filePath;
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

    return

    new GestureDetector(
    onTap: () async {
      location = await takePicture();
      print(location);

      setState(() {});

      var client = new http.Client();

      var response = await client.post(
        'https://westcentralus.api.cognitive.microsoft.com/face/v1.0/detect',
        headers: {
          'Content-Type': 'application/octet-stream',
          'Ocp-Apim-Subscription-Key': '1cfcc9173e2c4d50a0584a9a0b5bd532'
        },
        body: new File(location).readAsBytesSync()
      );

      var faces = json.decode(response.body);
      if(faces.length == 1) {
        Navigator.pop(context, faces[0]["faceId"]);
      }
    },
    child:
      new Padding(
          padding: new EdgeInsets.only(top: 40.0), child: new Scaffold(
        backgroundColor: Color.fromARGB(255, 100, 100, 100),
        body: new Column(
          children: <Widget>[
            new Padding(padding: new EdgeInsets.all(12.0), child: new Text(location == null ? "Stare at the camera" : "Detecting Face.. Please wait...")),
            new Padding(padding: new EdgeInsets.only(left: 45.0, right: 45.0), child: new AspectRatio(aspectRatio: controller.value.aspectRatio, child: location == null ? new CameraPreview(controller) : new Image.file(new File(location)))),
          ]
        )
      )
    )
    )

    ;


  }
}
