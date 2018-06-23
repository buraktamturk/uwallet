
import 'package:flutter/material.dart';
import 'tranfer.dart';
import 'database.dart';

class AccountPage extends StatefulWidget {
  AccountPage({Key key}) : super(key: key);

  @override
  _AccountPageState createState() => new _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
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
                onPressed: () async {

                  var money = await getTotalMoney();
                  print(money);

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
