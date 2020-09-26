import 'dart:ffi';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:working_time_management/models/eventsModel.dart';

class EventHelper {
  static EventHelper _databasehelper;
  static Database _database;

  String eventsTable = 'eventsTable';
  String colID = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colWorkTime = 'workTime';
  String colEmployer = 'employer';
  String colWorkers = 'workers';
  String colWorkersNumber = 'workersNumber';
  String colDayNumber = 'dayNumber';
  String colBreakTime = 'breakTime';
  String colHourSum = 'hourSum';
  String colIsPayed = 'isPayed';

  EventHelper._createInstance();

  factory EventHelper() {
    if (_databasehelper == null) {
      _databasehelper = EventHelper._createInstance();
    }
    return _databasehelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initialDatabase();
    }
    return _database;
  }

  Future<Database> initialDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'events.db';
    var employersDatabase =
        await openDatabase(path, version: 1, onCreate: _createDB);
    return employersDatabase;
  }

  void _createDB(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $eventsTable($colID INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colWorkTime TEXT, $colEmployer TEXT, $colWorkers TEXT, $colWorkersNumber INTEGER, $colDayNumber INTEGER, $colBreakTime INTEGER, $colHourSum REAL, $colIsPayed BOOLEAN)');
  }

  //wstawianie eventu
  Future<int> insertEvent(EventsModel eventsModel) async {
    Database db = await this.database;
    var result = await db.insert(eventsTable, eventsModel.toMap());
    return result;
  }

  //usuwanie eventu
  Future<int> deleteEvent(String title) async {
    Database db = await this.database;
    var result = await db
        .rawDelete('DELETE FROM $eventsTable WHERE $colTitle = "$title"');
    return result;
  }

  //pobieranie modelu eventu
  Future<EventsModel> getEventFromDB(String title) async {
    Database db = await database;
    var datas = await db
        .query("eventsTable", where: '$colTitle = ?', whereArgs: [title]);
    if (datas.length > 0) {
      return EventsModel.fromMapObject(datas.first);
    }
    return null;
  }

  //pobieranie sumy godzin dla danego pracodawcy
  Future<List> getHourEmployerSum(String name) async {
    Database db = await database;
    var datas = await db
        .rawQuery('SELECT * FROM $eventsTable WHERE $colEmployer="$name"');
    return datas;
  }

  //pobieranie sumy godzin dla danego pracownika
  Future<List> getHourWorkerSum(String name) async {
    Database db = await database;
    var datas = await db.rawQuery(
        'SELECT * FROM $eventsTable WHERE $colWorkers LIKE "%$name%"');
    return datas;
  }
}
