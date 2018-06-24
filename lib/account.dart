
import 'dart:convert';

import 'package:flutter/material.dart';
import 'tranfer.dart';
import 'package:qrcode_reader/QRCodeReader.dart';
import 'dart:async';
import 'database.dart';
import 'recognition.dart';
import 'package:http/http.dart' as http;

String faceId;

Future<String> loginWithBanking(BuildContext context) async {
  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();

  var token = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new TextField(
                controller: username,
                decoration: InputDecoration(
                  labelText: 'Login'
              ),),
              new TextField(
                controller: password,
                decoration: InputDecoration(
                  labelText: 'Password'
              ),),
              new Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: new RaisedButton(onPressed: () async {

                    var response = await http.post(
                        'https://api.eu-de.apiconnect.ibmcloud.com/eurobankgr-hackathon/hackathon/oauth/token',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                        body: 'grant_type=password&username=${username.text}&password=${password.text}'
                    );

                    print(response.body);
                    var xx = json.decode(response.body);

                    Navigator.pop(context, xx["access_token"]);

                  },
                    child: new Text("Login")
                  ))
            ],
          ),
        );
      });

  if(token == null) {
    throw new Exception('Authentication failed!');
  }

  return token;
}

Future<Map> selectAccount(BuildContext context, String token) async {
  var response = await http.get('https://api.eu-de.apiconnect.ibmcloud.com/eurobankgr-hackathon/hackathon/me/accounts',
      headers: {
        'Authorization': 'Bearer $token'
      });

  var accounts = json.decode(response.body)["accounts"];
  print(accounts);

  if(accounts == null || accounts.length == 0) {
    throw new Exception('no account found');
  }

  return await showDialog(context: context,
      builder: (context){
        return AlertDialog(
            content: new Column(
                mainAxisSize: MainAxisSize.min,
                children: accounts.map((a) => new ListTile(
                  onTap: () {
                    Navigator.of(context).pop(a);
                  },
                  // leading: new Text(a["accountNumber"]),
                  leading: const Icon(Icons.account_balance_wallet),
                  title: new Text(a["balanceAvailable"].toString() + "€"),
                  subtitle: new Row(
                    children: <Widget>[
                      new Text(a["productType"] ?? ""),
                      new Text(" / "),
                      new Text(a["description"] ?? "")
                    ],
                  ),
                )).cast<Widget>().toList()
            )
        );
      }
  );
}

Future<int> howMuch(BuildContext context, int limit) async {
  TextEditingController controller = new TextEditingController();

  return await showDialog(context: context,
      builder: (context){
        return AlertDialog(
            content: new Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                        labelText: 'Amount'
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: new RaisedButton(
                      child: new Text('Okay'),
                      onPressed: () {
                        Navigator.pop(context, int.parse(controller.text));
                      },
                    )
                  )
                ],
            )
        );
      }
  );
}

showSuccess(BuildContext context, String message) async {
  await showDialog(context: context,
      builder: (context){
        return AlertDialog(
            content: new Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                new Icon(Icons.insert_emoticon, color: Colors.green, size: 64.0),
                new Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: new Text(message, textAlign: TextAlign.center)
                )
              ],
            )
        );
      }
  );
}

showError(BuildContext context, String message) async {
  await showDialog(context: context,
      builder: (context){
        return AlertDialog(
            content: new Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                new Icon(Icons.error_outline, color: Colors.red, size: 64.0),
                new Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: new Text("Error: " + message, textAlign: TextAlign.center)
                )
              ],
            )
        );
      }
  );
}


authenticate(BuildContext context) async {


  if(faceId != null) {
    var id = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraApp()),
    );

    var response = await http.post(
        'https://westcentralus.api.cognitive.microsoft.com/face/v1.0/verify',
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': '1cfcc9173e2c4d50a0584a9a0b5bd532'
        },
        body: json.encode({
          "faceId1": faceId,
          "faceId2": id
        })
    );

    var xx = json.decode(response.body);

    if (xx["confidence"] > 0.8) {
      print("same person");
    } else {
      throw new Exception("not same person");
    }
  }
}

error(BuildContext context, Future e) async {
  try {
    await e;
  } catch(e) {
    showDialog(context: context, builder: (BuildContext context) {
      return new AlertDialog(
        content: new Text(e.message)
      );
    });

    throw e;
  }
}

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

                  await error(context, authenticate(context));


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
                onPressed: () async {
                  try {
                    var token = await loginWithBanking(context);
                    print(token);

                    var account = await selectAccount(context, token);
                    print(account);

                    var price = await howMuch(
                        context, account["balanceAvailable"].round());

                    print(price);

                    await testMoney(price);
                    var a = await getTotalMoney();

                    setState(() {
                      money = a;
                    });

                    await showSuccess(context,
                        "Your bank account balance was ${account["balanceAvailable"]}€, after the withdrawal of $price€, it became: ${account["balanceAvailable"] -
                            price}€");
                  } catch(e) {
                    showError(context, e.message);
                  }
                },
                child: new Text("LOAD IT FROM BANK ACCOUNT"),
              ),
            ),

            new Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: new RaisedButton(
                onPressed: () async {
                  try {
                    var token = await loginWithBanking(context);
                    print(token);

                    var account = await selectAccount(context, token);
                    print(account);

                    var price = await howMuch(context, account["balanceAvailable"].round());

                    print(price);

                    await splitMoney(price);
                    var a = await getTotalMoney();

                    setState(() { money = a; });

                    await showSuccess(context, "Your bank account balance was ${account["balanceAvailable"]}€ after the deposit of $price, it became: ${account["balanceAvailable"] + price}");
                  } catch(e) {
                    showError(context, e.message);
                  }
                },
                child: new Text("STORE IT IN BANK ACCOUNT"),
              ),
            ),

            new Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: new RaisedButton(
                onPressed: () async {
                  var id = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraApp()),
                  );

                  if(faceId == null) {
                    faceId = id;

                    setState(() { });
                  } else {
                    var response = await http.post(
                        'https://westcentralus.api.cognitive.microsoft.com/face/v1.0/verify',
                        headers: {
                          'Content-Type': 'application/json',
                          'Ocp-Apim-Subscription-Key': '1cfcc9173e2c4d50a0584a9a0b5bd532'
                        },
                        body: json.encode({
                          "faceId1": faceId,
                          "faceId2": id
                        })
                    );

                    var xx = json.decode(response.body);

                    if(xx["confidence"] > 0.8) {
                      print("same person");
                    } else {
                      print("not same person");
                    }
                  }
                },
                child: new Text(faceId == null ? "SETUP SECURITY" : "UNLOCK"),
              ),
            ),

          ],
        ),

      ),

    );
  }
}
