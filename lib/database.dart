
import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

Future<Database> priv_db;

Future<Database> _db() {
  Future<Database> __db() async {
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, "account.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE cash (id INTEGER PRIMARY KEY, token TEXT, serial INTEGER, amount INTEGER)");
        }
    );
  }

  if(priv_db == null) {
    priv_db = __db();
  }

  return priv_db;
}

Future<int> getTotalMoney() async {
  var db = await _db();

  var result = await db.rawQuery("SELECT SUM(amount) as amount FROM cash");

  return (result[0]["amount"] ?? 0);
}

Future directStore(String money) async {
  var parts2 = money.split('.');

  var db = await _db();
  await db.insert("cash", { "amount": parts2[0], "serial": parts2[1], "token": money });
}

Future appendMoney(String money) async {
  var parts = money.split('.');

  print(parts[0]);

  var result = await http.post('https://api.ecb.robinsoft.org/cash',
      headers: {
        "Content-Type": "application/json"
      },
      body: json.encode({
        "cashs": [
          money
        ],
        "amounts": [
          parts[0]
        ]
      })
  );

  var xx = json.decode(result.body)[0];

  await directStore(xx);
}

Future splitMoney(int amount) async {
  var ids = [];
  var tokens = [];

  var db = await _db();
  var results = await db.rawQuery("SELECT * FROM cash");

  int reached_amount = 0;
  for(var result in results) {
    ids.add(result["id"]);
    tokens.add(result["token"]);

    reached_amount += result["amount"];
    if(reached_amount >= amount) {

      var response = await http.post('https://api.ecb.robinsoft.org/cash',
          headers: {
            "Content-Type": "application/json"
          },
          body: json.encode({
            "cashs": tokens,
            "amounts": [
              amount,
              reached_amount - amount
            ].where((a) => a != 0).toList()
          })
      );

      var xx = json.decode(response.body);

      print(xx);

      for(var id in ids) {
        print(id);
        await db.delete("cash", where: "id = ?", whereArgs: [id]);
      }

      if(xx.length == 2) {
        await directStore(xx[1]);
      }

      return xx[0];
    }
  }

  throw new Exception("You do not have enought money for this operation.");
}

Future testMoney([int amount = 100]) async {
  var result = await http.get('https://api.ecb.robinsoft.org/test_money?amount=$amount');

  print(result.body);

  await appendMoney(result.body);
}
