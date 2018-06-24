
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr/qr.dart';
import 'database.dart';
import 'account.dart';
class TransferPage extends StatefulWidget {
  TransferPage({Key key}) : super(key: key);

  @override
  _TransferPageState createState() => new _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  bool buttonPressed = false;
  TextEditingController controller = new TextEditingController();

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
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Enter the amount of money to send'
              ),
            ),
            new FlatButton(
              onPressed: () async {
                print(controller.text);
                var code = await splitMoney(int.parse(controller.text));

                print("the code is:");
                print(code.substring(10, 20));

                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: new QrImage(data: code, version: 15, errorCorrectionLevel: QrErrorCorrectLevel.L, size: 250.0,
                        onError: (ex) {
                          print("[QR] ERROR - $ex");
                        },),
                    );
                  }
                );

                try {
                  await appendMoney(code);
                } catch(e) {

                }

                Navigator.pop(context);
              },
              child: new Text("SEND"),
            ),
          ],
        ),
      ),

    );
  }
}
