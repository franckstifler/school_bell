import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tableAlarm = 'alarm';
final String columnId = '_id';
final String columnDateTime = 'datetime';
final String columnRepeat = 'repeat';
final String columnActive = 'active';
final String columnDays = 'days';

class Alarm {
  int id;
  DateTime dateTime;
  bool repeat;
  bool active;
  List<Map<String, dynamic>> days = [
    {'day': 's', 'active': false, 'dayLong': 'Sun'},
    {'day': 'm', 'active': true, 'dayLong': 'Mon'},
    {'day': 't', 'active': true, 'dayLong': 'Tue'},
    {'day': 'w', 'active': true, 'dayLong': 'Wed'},
    {'day': 't', 'active': true, 'dayLong': 'Thu'},
    {'day': 'f', 'active': true, 'dayLong': 'Fri'},
    {'day': 's', 'active': false, 'dayLong': 'Sat'},
  ];

  Alarm({this.id, this.dateTime, this.repeat, this.active});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnDateTime: dateTime.toIso8601String(),
      columnRepeat: repeat == true ? 1 : 0,
      columnActive: active == true ? 1 : 0,
      columnDays: jsonEncode(days)
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Alarm.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    dateTime = DateTime.parse(map[columnDateTime]);
    repeat = map[columnRepeat] == 1;
    active = map[columnActive] == 1;
    days = List<Map<String, dynamic>>.from(jsonDecode(map[columnDays]));
  }
}

class AlarmProvider {
  static Database _db;

  AlarmProvider._();
  static final AlarmProvider db = AlarmProvider._();

  Future<Database> get database async {
    if (_db != null) {
      return _db;
    }
    _db = await open('alarm.db');
    return _db;
  }

  Future open(String path) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String p = join(documentsDirectory.path, path);
    try {
      return await openDatabase(p, version: 1, onCreate: _onCreate);
    } catch (e) {
      print(e);
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      create table $tableAlarm (
        $columnId integer primary key autoincrement,
        $columnDateTime text not null,
        $columnRepeat integer not null,
        $columnActive integer not null,
        $columnDays text not null)
        ''');
  }

  Future<Alarm> insertAlarm(Alarm alarm) async {
    final db = await database;
    alarm.id = await db.insert(tableAlarm, alarm.toMap());
    return alarm;
  }

  Future<int> updateAlarm(Alarm alarm) async {
    final db = await database;
    return await db.update(tableAlarm, alarm.toMap(), where: '$columnId = ?', whereArgs: [alarm.id]);
  }

  Future<List<Alarm>> getAlarms() async {
    final db = await database;
    List<Map> alarms = await db.query(tableAlarm,
        columns: [columnId, columnDateTime, columnActive, columnDays, columnRepeat]);
    return alarms.map((alarm) => Alarm.fromMap(alarm)).toList();
  }

  Future<Alarm> getAlarm({int id}) async {
    final db = await database;
    List<Map> alarms = await db.query(tableAlarm,
        columns: [columnId, columnDateTime, columnActive, columnRepeat],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (alarms.length > 0) {
      return Alarm.fromMap(alarms.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(tableAlarm, where: '$columnId = ?', whereArgs: [id]);
  }

  Future close() async => _db.close();
}
