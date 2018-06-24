
import 'dart:convert';

import 'package:flutter/material.dart';
import 'tranfer.dart';
import 'package:qrcode_reader/QRCodeReader.dart';
import 'dart:async';
import 'database.dart';
import 'recognition.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr/qr.dart';

Map mockedAmounts = new Map();

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
              new Padding(
                padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 5.0, bottom: 5.0),
                child: new Image.asset("assets/eurobank.png")
              ),
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
            content: new SafeArea(
            bottom: true,
            top: true,
            left: true,
            right: true,
            child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: accounts.map((a) => new SafeArea(
            bottom: true,
            top: true,
            left: true,
            right: true,
            child: new ListTile(
                  onTap: () {
                    Navigator.of(context).pop(a);
                  },
                  // leading: new Text(a["accountNumber"]),
                  leading: const Icon(Icons.account_balance_wallet),
                  title: new Text(((a["balanceAvailable"] + ((mockedAmounts.containsKey(a["accountNumber"]) ? mockedAmounts[a["accountNumber"]] : 0) * 1.0)).toString() + "€")),
                  subtitle: new SafeArea(
                      bottom: true,
                      top: true,
                      left: true,
                      right: true,
                      child: new Row(
                    children: <Widget>[
                      new Text(a["productType"] ?? "")
                    ],
                  )),
                ))).cast<Widget>().toList()
            )
        ));
      }
  );
}
List<int> bankNotes = [5,10,20,50,100,200,500];

class HowMuchPage extends StatefulWidget {
  dynamic update;

  HowMuchPage({Key key, this.update}) : super(key: key);

  @override
  _HowMuchPageState createState() => new _HowMuchPageState();
}

class _HowMuchPageState extends State<HowMuchPage> {
  int selected = 5;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
        items: bankNotes.map((int val) {
          return new DropdownMenuItem<int>(
            value: val,
            child: new Text(val.toString()),
          );
        }).toList(),
        value: selected,
        hint: Text("Please choose a banknote"),
        onChanged: (newVal) {
          selected = newVal;
          widget.update(newVal);
setState(() {});
        });
  }
}





Future<int> howMuch(BuildContext context, int limit) async {
  int selected_banknote = 5;

  return await showDialog(context: context,
      builder: (context){
        return AlertDialog(
            content: new Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                 /* new TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                        labelText: 'Amount'
                    ),
                  ),*/

                  HowMuchPage(update: (a) {
                    selected_banknote = a;
                  }),


                  new Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: new RaisedButton(
                      child: new Text('Okay'),
                      onPressed: () {
                        Navigator.pop(context, selected_banknote);
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
      throw new Exception("invalid authentication");
    }
  }
}

error(BuildContext context, Future e) async {
  try {
    await e;
  } catch(e) {
    showError(context, e.message);

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
  List moneys = [];



  int money = 0;

  @override
  void initState() {
    super.initState();

    getTotalMoney()
      .then((a) {
      setState(() { money = a; });
    });

    allMoney()
      .then((a) {
        setState(() {
          moneys = a;
        });
    });
  }

  Widget moneyx(Map money) {
    return new GestureDetector(
      onTap: () async {

        await authenticate(context);

        var code = money["token"];
        await delete(money["id"]);

        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: new QrImage(data: code,
                  version: 15,
                  errorCorrectionLevel: QrErrorCorrectLevel.L,
                  size: 250.0,
                  onError: (ex) {
                    print("[QR] ERROR - $ex");
                  },),
              );
            }
        );

        try {
          await appendMoney(code);
        } catch (e) {

        }

        var c = await getTotalMoney();

        setState(() { this.money = c; });


        var b = await allMoney();
        moneys = b;
        setState(() {

        });

      },
    child: new Card(
      child:  Container(
      width: 160.0,
      child: new Column(
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.only(top: 48.0),
        child: new Text(money["amount"].toString() + "€", style: Theme.of(context).textTheme.display2)),
          new Padding(
            padding: EdgeInsets.only(top: 48.0),
            child: new Text(money["serial"].toString(), style: Theme.of(context).textTheme.body2)
          )
        ],
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("U-Wallet"),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(faceId == null ? Icons.lock_outline : Icons.lock_open),
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
                    faceId = null;

                    setState(() { });
                  } else {
                    showError(context, "invalid authentication");
                  }
                }
              },
            ),
          ],
      ),
      body: new Center(
        child: new SingleChildScrollView(
    child: new Column(

          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20.0),
              height: 200.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: moneys.map((a) => moneyx(a)).toList(),
              ),
            ),

            new Padding(
              padding: const EdgeInsets.only(top: 5.0, right: 5.0),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    new Text(
                        'Total: $money€',
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.right,
                      textScaleFactor: 1.5,
                      )
                  ]
              ),
            ),

            new Padding(
              padding: EdgeInsets.only(left: 72.0, right: 72.0, top: 24.0),
              child: new Image.asset("assets/eurobank.png")
            ),

            new Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: new RaisedButton(
                onPressed: () async {
                  try {
                    await authenticate(context);

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


                    var b = await allMoney();
                    moneys = b;
                    setState(() {

                    });


                    await showSuccess(context,
                        "Your bank account balance was ${account["balanceAvailable"]}€, after the withdrawal of $price€, it became: ${account["balanceAvailable"] -
                            price}€");

                    if(mockedAmounts.containsKey(account["accountNumber"])) {
                      mockedAmounts[account["accountNumber"]] -= price;
                    } else {
                      mockedAmounts[account["accountNumber"]] = -price;
                    }
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
                    await authenticate(context);

                    var token = await loginWithBanking(context);
                    print(token);

                    var account = await selectAccount(context, token);
                    print(account);

                    var price = await howMuch(context, account["balanceAvailable"].round());

                    print(price);

                    await splitMoney(price);
                    var a = await getTotalMoney();

                    setState(() { money = a; });


                    var b = await allMoney();
                    moneys = b;
                    setState(() {

                    });

                    await showSuccess(context, "Your bank account balance was ${account["balanceAvailable"]}€ after the deposit of $price, it became: ${account["balanceAvailable"] + price}");

                    if(mockedAmounts.containsKey(account["accountNumber"])) {
                      mockedAmounts[account["accountNumber"]] += price;
                    } else {
                      mockedAmounts[account["accountNumber"]] = price;
                    }
                  } catch(e) {
                    showError(context, e.message);
                  }
                },
                child: new Text("STORE IT IN BANK ACCOUNT"),
              ),
            ),

/*
            new Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: new RaisedButton(
                onPressed: () async {

                  try {
                    await authenticate(context);

                    var price = await howMuch(context, 100);

                    var code = await splitMoney(price);

                    await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: new QrImage(data: code,
                              version: 15,
                              errorCorrectionLevel: QrErrorCorrectLevel.L,
                              size: 250.0,
                              onError: (ex) {
                                print("[QR] ERROR - $ex");
                              },),
                          );
                        }
                    );

                    try {
                      await appendMoney(code);
                    } catch (e) {

                    }
                  } catch(e) {
                    await showError(context, e.message);
                  }

                  var a = await getTotalMoney();

                  setState(() { money = a; });


                  var b = await allMoney();
                  moneys = b;
                  setState(() {

                  });
                },
                child: new Text("SEND MONEY"),
              ),
            ),
*/
            new Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: new RaisedButton(
                color: Colors.deepOrange,
                textColor: Colors.white,
                onPressed: () async {
                  var data = await new QRCodeReader().scan();

                  print(data);

                  await appendMoney(data);

                  var a = await getTotalMoney();

                  setState(() { money = a; });


                  var b = await allMoney();
                  moneys = b;
                  setState(() {

                  });

                },
                child: new Text("RECEIVE MONEY"),
              ),
            ),
          ],
        ),

      ),

    ));
  }
}
