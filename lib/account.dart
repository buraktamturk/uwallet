
import 'package:flutter/material.dart';
import 'tranfer.dart';
import 'package:qrcode_reader/QRCodeReader.dart';
import 'dart:async';
import 'database.dart';
import 'recognition.dart';

class AccountPage extends StatefulWidget {
  AccountPage({Key key}) : super(key: key);

  @override
  _AccountPageState createState() => new _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Future<String> futureString;
  String test;

  int money = 0;

  @override
  void initState() {
    super.initState();

    getTotalMoney()
      .then((a) {
      setState(() { money = a; });
    });

  }

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
                      '$money€',
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
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TransferPage()),
                  );

                  var a = await getTotalMoney();

                  setState(() { money = a; });
                },
                child: new Text("SEND MONEY"),
              ),
            ),

            new Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: new RaisedButton(
                onPressed: () async {
                  var data = await new QRCodeReader().scan();

                  print(data);

                  await appendMoney(data);

                  var a = await getTotalMoney();

                  setState(() { money = a; });

                },
                child: new Text("RECEIVE MONEY"),
              ),
            ),

            new Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: new RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraApp()),
                  );
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

            new Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: new RaisedButton(
                onPressed: () async {

                  await testMoney();
                  var a = await getTotalMoney();

                  setState(() { money = a; });

                },
                child: new Text("TEST MONEY"),
              ),
            ),

          ],
        ),

      ),

    );
  }
}
