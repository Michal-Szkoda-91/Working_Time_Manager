import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:working_time_management/models/workersModel.dart';

class WorkersHelper {
  static WorkersHelper _databasehelper;
  static Database _database;

  String workersTable = 'workersTable';
  String colID = 'id';
  String colname = 'name';
  String colshortName = 'shortName';
  String colhoursSum = 'hoursSum';
  String coladditions = 'additions';
  String colnotes = 'notes';

  WorkersHelper._createInstance();

  factory WorkersHelper() {
    if (_databasehelper == null) {
      _databasehelper = WorkersHelper._createInstance();
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
    String path = directory.path + 'workers.db';
    var workersDatabase =
        await openDatabase(path, version: 1, onCreate: _createDB);
    return workersDatabase;
  }

  void _createDB(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $workersTable($colID INTEGER PRIMARY KEY AUTOINCREMENT, $colname TEXT, $colshortName TEXT, $colhoursSum REAL, $coladditions TEXT, $colnotes TEXT)');
  }

  //pobieranie pracownikow w postaci map
  Future<List<Map<String, dynamic>>> getWorkersMapList() async {
    Database db = await this.database;
    var result = await db.query(workersTable,
        orderBy:
            '$colname ASC'); //sortowanie pracownikow alfabetycznie po nazwie
    return result;
  }

  //wstawianie pracownika
  Future<int> insertWorker(WorkersModel workersModel) async {
    Database db = await this.database;
    var result = await db.insert(workersTable, workersModel.toMap());
    return result;
  }

  //update pracownika
  Future<int> updateWorkers(WorkersModel workersModel) async {
    Database db = await this.database;
    var result = await db.update(workersTable, workersModel.toMap(),
        where: '$colID = ?', whereArgs: [workersModel.id]);
    return result;
  }

  //usuwanie pracownika
  Future<int> deleteWorker(int id) async {
    Database db = await this.database;
    var result =
        await db.rawDelete('DELETE FROM $workersTable WHERE $colID = $id');
    return result;
  }

  //pobieranie numeru pracownika
  Future<int> getWorkersCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $workersTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //pobieranie Mapy z lista i konwersja do zwyklej listy
  Future<List<WorkersModel>> getWorkersList() async {
    var workersListMap = await getWorkersMapList();
    int count = workersListMap.length;

    List<WorkersModel> workersList = List<WorkersModel>();
    for (int i = 0; i < count; i++) {
      workersList.add(WorkersModel.fromMapObject((workersListMap[i])));
    }
    return workersList;
  }

  //POBIERANIE pojedynczej kolumny do listy
  Future<List<WorkersModel>> getShortNameList() async {
    Database db = await this.database;
    var response = await db.rawQuery('SELECT $colshortName from $workersTable');
    List<WorkersModel> list =
        response.map((c) => WorkersModel.fromMapObject(c)).toList();
    return list;
  }

  //sprawdzanie czy jest juz pracownik o tym samym imieniu
  Future<int> getWorkerName(String nameGet) async {
    Database db = await this.database;
    var queryResult = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) from $workersTable WHERE $colname="$nameGet"'));
    return queryResult;
  }

  //uaktualnianie wartosci sumy godzin
  Future<int> updateHoursSum(double sum, String shortName) async {
    Database db = await this.database;
    return await db.rawUpdate('''
    UPDATE workersTable 
    SET hoursSum = ?
    WHERE shortName = ?
    ''', [sum, shortName]);
  }

//uaktualnianie listydodatkow
  Future<int> updateAdditions(String textToWrite, String shortName) async {
    Database db = await this.database;
    return await db.rawUpdate('''
    UPDATE workersTable 
    SET additions = ?
    WHERE shortName = ?
    ''', [textToWrite, shortName]);
  }

//uaktualnianie listy dni przepracowanych
  Future<int> updateNotes(String textToWrite, String shortName) async {
    Database db = await this.database;
    return await db.rawUpdate('''
    UPDATE workersTable 
    SET notes = ?
    WHERE shortName = ?
    ''', [textToWrite, shortName]);
  }
}
