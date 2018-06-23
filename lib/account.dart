
import 'package:flutter/material.dart';
import 'tranfer.dart';
import 'package:qrcode_reader/QRCodeReader.dart';
import 'dart:async';

class AccountPage extends StatefulWidget {
  AccountPage({Key key}) : super(key: key);

  @override
  _AccountPageState createState() => new _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Future<String> futureString;
  String test;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("U-Wallet"),
      ),
      body: new Center(
        child: new Column(

          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.only(top: 64.0),
              child: new Column(
                  children: [
                    new Text(
                        'You have'
                    ),

                    new Text(
                      '0€',
                      style: Theme.of(context).textTheme.display3,
                    ),

                    new Text(
                        'on your wallet.'
                    ),

                  ]
              ),
            ),


            new Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: new RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TransferPage()),
                  );
                },
                child: new Text("SEND MONEY"),
              ),
            ),

            new Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: new RaisedButton(
                onPressed: () {
                  setState(() {
                    futureString = new QRCodeReader().scan().then((test){
                      return showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text(test),
                            );
                          });
                    });
                    test = futureString.toString();
                    

                  });

                },
                child: new Text("RECEIVE MONEY"),
              ),
            ),

            new Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: new RaisedButton(
                onPressed: () {

                },
                child: new Text("LOAD IT FROM BANK ACCOUNT"),
              ),
            ),

            new Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: new RaisedButton(
                onPressed: () {
                    if(futureString != null){
                      return showDialog(
                      context: context,
                      builder: (context) {
                      return AlertDialog(
                    content: Text(test),
                      );
                    });}


                },
                child: new Text("STORE IT IN BANK ACCOUNT"),
              ),
            ),

          ],
        ),

      ),

    );
  }
}
