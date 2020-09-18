import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:working_time_management/models/employersModel.dart';

class EmployersHelper {
  static EmployersHelper _databasehelper;
  static Database _database;

  String employersTable = 'employersTable';
  String colID = 'id';
  String colname = 'name';
  String colshortName = 'shortName';
  String colhoursSum = 'hoursSum';
  String coladditions = 'additions';
  String colnotes = 'notes';

  EmployersHelper._createInstance();

  factory EmployersHelper() {
    if (_databasehelper == null) {
      _databasehelper = EmployersHelper._createInstance();
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
    String path = directory.path + 'employers.db';
    var employersDatabase =
        await openDatabase(path, version: 1, onCreate: _createDB);
    return employersDatabase;
  }

  void _createDB(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $employersTable($colID INTEGER PRIMARY KEY AUTOINCREMENT, $colname TEXT, $colshortName TEXT, $colhoursSum REAL, $coladditions TEXT, $colnotes TEXT)');
  }

  //pobieranie pracownikow w postaci map
  Future<List<Map<String, dynamic>>> getEmployersMapList() async {
    Database db = await this.database;
    var result = await db.query(employersTable,
        orderBy:
            '$colname ASC'); //sortowanie pracownikow alfabetycznie po nazwie
    return result;
  }

  //wstawianie pracownika
  Future<int> insertEmployer(EmployersModel employersModel) async {
    Database db = await this.database;
    var result = await db.insert(employersTable, employersModel.toMap());
    return result;
  }

  //update pracownika
  Future<int> updateEmployers(EmployersModel employersModel) async {
    Database db = await this.database;
    var result = await db.update(employersTable, employersModel.toMap(),
        where: '$colID = ?', whereArgs: [employersModel.id]);
    return result;
  }

  //usuwanie pracownika
  Future<int> deleteEmployer(int id) async {
    Database db = await this.database;
    var result =
        await db.rawDelete('DELETE FROM $employersTable WHERE $colID = $id');
    return result;
  }

  //pobieranie numeru pracownika
  Future<int> getEmployersCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $employersTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //pobieranie Mapy z lista i konwersja do zwyklej listy
  Future<List<EmployersModel>> getEmployersList() async {
    var employersListMap = await getEmployersMapList();
    int count = employersListMap.length;

    List<EmployersModel> employersList = List<EmployersModel>();
    for (int i = 0; i < count; i++) {
      employersList.add(EmployersModel.fromMapObject((employersListMap[i])));
    }
    return employersList;
  }

  //POBIERANIE pojedynczej kolumny do listy
  Future<List<EmployersModel>> getNameList() async {
    Database db = await this.database;
    var response = await db.rawQuery('SELECT $colname from $employersTable');
    List<EmployersModel> list =
        response.map((c) => EmployersModel.fromMapObject(c)).toList();
    return list;
  }

  //sprawdzanie czy jest juz pracownik o tym samym imieniu
  Future<int> getEmployerName(String nameGet) async {
    Database db = await this.database;
    var queryResult = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) from $employersTable WHERE $colname="$nameGet"'));
    return queryResult;
  }

  //uaktualnianie wartosci sumy godzin
  Future<int> updateHoursSum(double sum, String shortName) async {
    Database db = await this.database;
    return await db.rawUpdate('''
    UPDATE employersTable 
    SET hoursSum = ?
    WHERE shortName = ?
    ''', [sum, shortName]);
  }

//uaktualnianie listydodatkow
  Future<int> updateAdditions(String textToWrite, String shortName) async {
    Database db = await this.database;
    return await db.rawUpdate('''
    UPDATE employersTable 
    SET additions = ?
    WHERE shortName = ?
    ''', [textToWrite, shortName]);
  }

//uaktualnianie listy dni przepracowanych
  Future<int> updateNotes(String textToWrite, String shortName) async {
    Database db = await this.database;
    return await db.rawUpdate('''
    UPDATE employersTable 
    SET notes = ?
    WHERE shortName = ?
    ''', [textToWrite, shortName]);
  }
}
