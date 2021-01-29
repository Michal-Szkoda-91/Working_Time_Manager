import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:working_time_management/models/eventsModel.dart';

class EventHelper {
  static EventHelper _databasehelper;
  static Database _database;

  String _eventsTable = '_eventsTable';
  String _colID = 'id';
  String _colTitle = 'title';
  String _colDate = 'date';
  String _colWorkTime = 'workTime';
  String _colEmployer = 'employer';
  String _colWorkersNotPaid = 'workersNotPaid';
  String _colWorkersPaid = 'workersPaid';
  String _colWorkersNumber = 'workersNumber';
  String _colDayNumber = 'dayNumber';
  String _colBreakTime = 'breakTime';
  String _colHourSum = 'hourSum';
  String _colIsPaid = 'isPaid';

  EventHelper._createInstance();

  //
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
        'CREATE TABLE $_eventsTable($_colID INTEGER PRIMARY KEY AUTOINCREMENT, $_colTitle TEXT, $_colDate TEXT, $_colWorkTime TEXT, $_colEmployer TEXT, $_colWorkersNotPaid TEXT, $_colWorkersPaid TEXT, $_colWorkersNumber INTEGER, $_colDayNumber INTEGER, $_colBreakTime INTEGER, $_colHourSum REAL, $_colIsPaid BOOLEAN)');
  }

  //wstawianie eventu
  Future<int> insertEvent(EventsModel eventsModel) async {
    Database db = await this.database;
    var result = await db.insert(_eventsTable, eventsModel.toMap());
    return result;
  }

  //update eventu, zmiana stanu zaplacony
  Future<int> updateEvent(int isPaid, int id) async {
    Database db = await this.database;
    var result = await db.rawUpdate(
        "UPDATE $_eventsTable SET $_colIsPaid = $isPaid WHERE $_colID = $id");
    return result;
  }

  //usuwanie eventu
  Future<int> deleteEvent(String title) async {
    Database db = await this.database;
    var result = await db
        .rawDelete('DELETE FROM $_eventsTable WHERE $_colTitle = "$title"');
    return result;
  }

  //pobieranie modelu eventu
  Future<EventsModel> getEventFromDB(String title) async {
    Database db = await database;
    var datas = await db
        .query("_eventsTable", where: '$_colTitle = ?', whereArgs: [title]);
    if (datas.length > 0) {
      return EventsModel.fromMapObject(datas.first);
    }
    return null;
  }

  //pobieranie listy eventów z wybranym imieniem  pracodawcy ze statusem niezapłacony
  Future<List> getHourEmployerSum(String name) async {
    Database db = await database;
    var datas = await db.rawQuery(
        'SELECT * FROM $_eventsTable WHERE $_colEmployer="$name" AND $_colIsPaid=0');
    return datas;
  }

  //pobieranie listy eventow z wybranym tytulem
  Future<List> getEventsList(String title) async {
    Database db = await database;
    var datas = await db
        .rawQuery('SELECT * FROM $_eventsTable WHERE $_colTitle="$title"');
    return datas;
  }

  //pobieranie pracownikow w postaci map
  Future<List<Map<String, dynamic>>> getEventsMapList() async {
    Database db = await this.database;
    var result = await db.query(_eventsTable, orderBy: '$_colID ASC');
    return result;
  }

  //pobieranie listy eventow
  Future<List<EventsModel>> getEventAllList() async {
    var eventListMap = await getEventsMapList();
    int count = eventListMap.length;

    List<EventsModel> eventsList = List<EventsModel>();
    for (int i = 0; i < count; i++) {
      eventsList.add(EventsModel.fromMapObject((eventListMap[i])));
    }
    return eventsList;
  }

  //pobieranie listy eventow z wybranym imieniem pracodawcy, bez rozróżnienia na to czy jest zapłacone
  Future<List> getEmployersEventsList(String name) async {
    Database db = await database;
    var datas = await db
        .rawQuery('SELECT * FROM $_eventsTable WHERE $_colEmployer="$name"');
    return datas;
  }

  //pobieranie listy eventow z wybranym imieniem pracownika, bez rozróżnienia na to czy jest zapłacone
  Future<List> getWorkersEventsList(String shortname) async {
    Database db = await database;
    var datas = await db.rawQuery(
        'SELECT * FROM $_eventsTable WHERE $_colWorkersNotPaid LIKE "%$shortname%" OR $_colWorkersPaid LIKE "%$shortname%" ');
    return datas;
  }

  //pobieranie listy eventow z wybranym imieniem pracownika, jeśli jest na liście 'niezapłacone'
  Future<List> getWorkersEventsListNotPaid(String shortname) async {
    Database db = await database;
    var datas = await db.rawQuery(
        'SELECT * FROM $_eventsTable WHERE $_colWorkersNotPaid LIKE "%$shortname%" ');
    return datas;
  }

  //pobieranie listy eventow z wybranym imieniem pracownika, jeśli jest na liście 'zapłacone'
  Future<List> getWorkersEventsListPaid(String shortname) async {
    Database db = await database;
    var datas = await db.rawQuery(
        'SELECT * FROM $_eventsTable WHERE $_colWorkersPaid LIKE "%$shortname%" ');
    return datas;
  }

//zapisanie do eventu listy pracownikow nie zaplaconych
  Future<int> updateWorkersNotPaid(int id, String list) async {
    Database db = await this.database;
    var result = await db.rawUpdate(
        "UPDATE $_eventsTable SET $_colWorkersNotPaid = '$list' WHERE $_colID = $id");
    return result;
  }

  //zapisanie do eventu listy pracownikow nie zaplaconyc
  Future<int> updateWorkersPaid(int id, String list) async {
    Database db = await this.database;
    var result = await db.rawUpdate(
        "UPDATE $_eventsTable SET $_colWorkersPaid = '$list' WHERE $_colID = $id");
    return result;
  }
}
