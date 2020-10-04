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
  String colWorkersNotPaid = 'workersNotPaid';
  String colWorkersPaid = 'workersPaid';
  String colWorkersNumber = 'workersNumber';
  String colDayNumber = 'dayNumber';
  String colBreakTime = 'breakTime';
  String colHourSum = 'hourSum';
  String colIsPaid = 'isPaid';

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
        'CREATE TABLE $eventsTable($colID INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colWorkTime TEXT, $colEmployer TEXT, $colWorkersNotPaid TEXT, $colWorkersPaid TEXT, $colWorkersNumber INTEGER, $colDayNumber INTEGER, $colBreakTime INTEGER, $colHourSum REAL, $colIsPaid BOOLEAN)');
  }

  //wstawianie eventu
  Future<int> insertEvent(EventsModel eventsModel) async {
    Database db = await this.database;
    var result = await db.insert(eventsTable, eventsModel.toMap());
    return result;
  }

  //update eventu, zmiana stanu zaplacony
  Future<int> updateEvent(int isPaid, int id) async {
    Database db = await this.database;
    var result = await db.rawUpdate(
        "UPDATE $eventsTable SET $colIsPaid = $isPaid WHERE $colID = $id");
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

  //pobieranie listy eventów z wybranym imieniem  pracodawcy ze statusem niezapłacony
  Future<List> getHourEmployerSum(String name) async {
    Database db = await database;
    var datas = await db.rawQuery(
        'SELECT * FROM $eventsTable WHERE $colEmployer="$name" AND $colIsPaid=0');
    return datas;
  }

  //pobieranie listy eventow z wybranym tytulem
  Future<List> getEventsList(String title) async {
    Database db = await database;
    var datas = await db
        .rawQuery('SELECT * FROM $eventsTable WHERE $colTitle="$title"');
    return datas;
  }

  //pobieranie listy eventow z wybranym imieniem pracodawcy, bez rozróżnienia na to czy jest zapłacone
  Future<List> getEmployersEventsList(String name) async {
    Database db = await database;
    var datas = await db
        .rawQuery('SELECT * FROM $eventsTable WHERE $colEmployer="$name"');
    return datas;
  }

  //pobieranie listy eventow z wybranym imieniem pracownika, bez rozróżnienia na to czy jest zapłacone
  Future<List> getWorkersEventsList(String shortname) async {
    Database db = await database;
    var datas = await db.rawQuery(
        'SELECT * FROM $eventsTable WHERE $colWorkersNotPaid LIKE "%$shortname%" OR $colWorkersPaid LIKE "%$shortname%" ');
    return datas;
  }

  //pobieranie listy eventow z wybranym imieniem pracownika, jeśli jest na liście 'niezapłacone'
  Future<List> getWorkersEventsListNotPaid(String shortname) async {
    Database db = await database;
    var datas = await db.rawQuery(
        'SELECT * FROM $eventsTable WHERE $colWorkersNotPaid LIKE "%$shortname%" ');
    return datas;
  }

  //pobieranie listy eventow z wybranym imieniem pracownika, jeśli jest na liście 'zapłacone'
  Future<List> getWorkersEventsListPaid(String shortname) async {
    Database db = await database;
    var datas = await db.rawQuery(
        'SELECT * FROM $eventsTable WHERE $colWorkersPaid LIKE "%$shortname%" ');
    return datas;
  }

//zapisanie do eventu listy pracownikow nie zaplaconych
  Future<int> updateWorkersNotPaid(int id, String list) async {
    Database db = await this.database;
    var result = await db.rawUpdate(
        "UPDATE $eventsTable SET $colWorkersNotPaid = '$list' WHERE $colID = $id");
    return result;
  }

  //zapisanie do eventu listy pracownikow nie zaplaconyc
  Future<int> updateWorkersPaid(int id, String list) async {
    Database db = await this.database;
    var result = await db.rawUpdate(
        "UPDATE $eventsTable SET $colWorkersPaid = '$list' WHERE $colID = $id");
    return result;
  }
}
