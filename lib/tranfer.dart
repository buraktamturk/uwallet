
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TransferPage extends StatefulWidget {
  TransferPage({Key key}) : super(key: key);

  @override
  _TransferPageState createState() => new _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  bool buttonPressed = false;

  QrImage image = new QrImage(data: "WhatTheHack Eurobank's Beyond Hackathon 2018 Winnners",size: 200.0);
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Transfer"),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Enter the amount of money to send'
              ),
            ),
            new FlatButton(
              onPressed: () {
              return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                  content: image,


//                    content: Text("asasd"),
              );


//                setState(() {
//                  buttonPressed = true;
//                  image = new QrImage(data: )
//                );
              },
              );
              },
              child: new Text("SEND"),
            ),
            buttonPressed ? image : new Text("")
          ],
        ),
      ),

    );
  }
}
