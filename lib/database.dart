
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

Future<Database> priv_db;

Future<Database> _db() {
  Future<Database> __db() async {
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, "account.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE cash (id INTEGER PRIMARY KEY, token TEXT, id INTEGER, amount INTEGER)");
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

  return result[0]["amount"] + 1;
}

