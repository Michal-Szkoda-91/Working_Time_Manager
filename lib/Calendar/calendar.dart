import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:working_time_management/Calendar/eventDetailScreen.dart';
import 'package:working_time_management/Calendar/widgets.dart';
import 'package:working_time_management/helpers/employersHelper.dart';
import 'package:working_time_management/helpers/eventHelper.dart';
import 'package:working_time_management/helpers/workersHelper.dart';
import 'package:working_time_management/models/employersModel.dart';
import 'package:working_time_management/models/eventsModel.dart';
import 'package:working_time_management/models/workersModel.dart';

import '../globals.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarController _controller;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  SharedPreferences _prefs;
  String _employerNameValue;
  String choosenEmployerName;
  String _titleCreated;

  //EVENTY - BAZA DANYCH

  EventHelper eventHelper = EventHelper();
  EventsModel eventsModel;
  List<EventsModel> _eventsModelList;
  int eventsLenght = 0;

  //PRACODAWCY i PRACOWNICY
  //dane pracodawców
  EmployersHelper employersHelper = EmployersHelper();
  List<EmployersModel> _employersModelList;
  int employersLenght = 0;

  //dane pracowników
  WorkersHelper workersHelper = WorkersHelper();
  List<WorkersModel> _workersModelList;
  int workersLenght = 0;

  //pobieranie listy modeli eventow
  void _updateListViewEvents() {
    final Future<Database> dbFuture = eventHelper.initialDatabase();
    dbFuture.then((databse) {
      Future<List<EventsModel>> eventModelListFuture =
          eventHelper.getEventAllList();
      eventModelListFuture.then((_eventsModelList) {
        if (this.mounted)
          setState(() {
            this._eventsModelList = _eventsModelList;
            this.eventsLenght = _eventsModelList.length;
          });
      });
    });
  }

  //pobieranie listy modeli pracodawców
  void _updateListViewEmployers() {
    final Future<Database> dbFuture = employersHelper.initialDatabase();
    dbFuture.then((databse) {
      Future<List<EmployersModel>> employersModelListFuture =
          employersHelper.getEmployersList();
      employersModelListFuture.then((_employersModelList) {
        if (this.mounted)
          setState(() {
            this._employersModelList = _employersModelList;
            this.employersLenght = _employersModelList.length;
          });
      });
    });
  }

  //pobieranie listy modeli pracodawców
  void _updateListViewWorkers() {
    final Future<Database> dbFuture = workersHelper.initialDatabase();
    dbFuture.then((databse) {
      Future<List<WorkersModel>> workersModelListFuture =
          workersHelper.getWorkersList();
      workersModelListFuture.then((_workersModelList) {
        if (this.mounted)
          setState(() {
            this._workersModelList = _workersModelList;
            this.workersLenght = _workersModelList.length;
          });
      });
    });
  }

  //metoda tworzaca liste imion Pracodawcow z bazy danych
  void _createNameList() {
    employersNameList = [];
    workersShortNameList = [];
    for (int i = 0; i < employersLenght; i++) {
      employersNameList.add(this._employersModelList[i].name);
    }
    for (int i = 0; i < workersLenght; i++) {
      workersShortNameList.add(this._workersModelList[i].shortName);
    }
  }

  //pobranie wybranego numeru wg imion
  int _choosenNameNumberEmployer(String name) {
    return employersNameList.indexOf(name);
  }

  //pobranie wybranego numeru wg imion
  int choosenNameNumberWorker(String name) {
    return workersShortNameList.indexOf(name);
  }

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _events = {};
    _selectedEvents = [];
    _initPrefs();
    _updateListViewEmployers();
    _updateListViewWorkers();
    _updateListViewEvents();
  }

  //PREFERENCJE

  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          _decodeMap(json.decode(_prefs.getString("events") ?? "{}")));
    });
  }

  //metoda ladujaca event do share-preference
  Map<String, dynamic> _encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  //metoda pobierajaca z share event
  Map<DateTime, dynamic> _decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }

  @override
  Widget build(BuildContext context) {
    _updateListViewEmployers();
    _updateListViewWorkers();
    _updateListViewEvents();
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TableCalendar(
            // locale: 'pl_PL',
            events: _events,
            initialCalendarFormat: CalendarFormat.month,
            calendarStyle: CalendarStyle(
              markersColor: Theme.of(context).hintColor,
              todayColor: Theme.of(context).cardColor,
              selectedColor: Theme.of(context).backgroundColor,
              canEventMarkersOverflow: true,
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle(
              centerHeaderTitle: false,
              titleTextStyle:
                  TextStyle(color: Theme.of(context).hintColor, fontSize: 20),
              formatButtonDecoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(2.0)),
              formatButtonTextStyle:
                  TextStyle(color: Theme.of(context).hoverColor),
              formatButtonShowsNext: false,
            ),
            startingDayOfWeek: StartingDayOfWeek.monday,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle:
                  TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
              weekendStyle:
                  TextStyle(color: Theme.of(context).cardColor, fontSize: 14),
            ),
            onDaySelected: (date, events, _events) {
              //zdarzenie po kliknieciu w dzien
              setState(() {
                _selectedEvents = events;
              });
            },
            //budowanie dni kalendarza
            builders: CalendarBuilders(
              //************************************************ */
              weekendDayBuilder: (context, date, events) => Container(
                margin: const EdgeInsets.all(0.5),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: Theme.of(context).hintColor),
                    borderRadius: BorderRadius.circular(2.0)),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    //*********************************** */
                    //Warunki sprawdzajace czy dany event jest oplacony calkowicie czy nie
                    //jesli nie ma eventow buduje normalny dzien
                    if (_events[date] == null ||
                        _events[date].toString() == "[]")
                      Container(
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(1.0)),
                              child: Text(
                                date.day.toString(),
                                style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    //jesli sa eventy i wszystkie sa zaplacone u pracodawcow buduje dzien z kolorem zielonym
                    if (_events[date] != null &&
                        _events[date].toString() != "[]" &&
                        _checkIfEventIsPaidCalendar(
                            _events[date], _eventsModelList))
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Theme.of(context).indicatorColor,
                                borderRadius: BorderRadius.circular(1.0)),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          if (_events[date].length > 0)
                            Text(
                              _getEmployerShortName(
                                  _events[date][0], _eventsModelList),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                        ],
                      ),
                    //jesli eventy sa i chociaz jeden jest nie oplacony buduje dzien czerwony
                    if (_events[date] != null &&
                        _events[date].toString() != "[]" &&
                        !_checkIfEventIsPaidCalendar(
                            _events[date], _eventsModelList))
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Theme.of(context).errorColor,
                                borderRadius: BorderRadius.circular(1.0)),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          if (_events[date].length > 0)
                            Text(
                              _getEmployerShortName(
                                  _events[date][0], _eventsModelList),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              //********************************************************************************* */
              dayBuilder: (context, date, events) => Container(
                margin: const EdgeInsets.all(0.5),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: Theme.of(context).hintColor),
                    borderRadius: BorderRadius.circular(2.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    //*********************************** */
                    //Warunki sprawdzajace czy dany event jest oplacony calkowicie czy nie
                    //jesli nie ma eventow buduje normalny dzien
                    if (_events[date] == null ||
                        _events[date].toString() == "[]")
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Theme.of(context).selectedRowColor,
                                borderRadius: BorderRadius.circular(1.0)),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    //jesli sa eventy i wszystkie sa zaplacone u pracodawcow buduje dzien z kolorem zielonym
                    if (_events[date] != null &&
                        _events[date].toString() != "[]" &&
                        _checkIfEventIsPaidCalendar(
                            _events[date], _eventsModelList))
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Theme.of(context).indicatorColor,
                                borderRadius: BorderRadius.circular(1.0)),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          if (_events[date].length > 0)
                            Text(
                              _getEmployerShortName(
                                  _events[date][0], _eventsModelList),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                        ],
                      ),
                    //jesli eventy sa i chociaz jeden jest nie oplacony buduje dzien czerwony
                    if (_events[date] != null &&
                        _events[date].toString() != "[]" &&
                        !_checkIfEventIsPaidCalendar(
                            _events[date], _eventsModelList))
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Theme.of(context).errorColor,
                                borderRadius: BorderRadius.circular(1.0)),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          if (_events[date].length > 0)
                            Text(
                              _getEmployerShortName(
                                  _events[date][0], _eventsModelList),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              //******************************************************************************* */
              //Dzien wybrany
              selectedDayBuilder: (context, date, events) => Container(
                margin: const EdgeInsets.all(0.5),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 2, color: Theme.of(context).cardColor),
                    borderRadius: BorderRadius.circular(2.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    //*********************************** */
                    //Warunki sprawdzajace czy dany event jest oplacony calkowicie czy nie
                    //jesli nie ma eventow buduje normalny dzien
                    if (_events[date] == null ||
                        _events[date].toString() == "[]")
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Theme.of(context).selectedRowColor,
                                borderRadius: BorderRadius.circular(1.0)),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    //jesli sa eventy i wszystkie sa zaplacone u pracodawcow buduje dzien z kolorem zielonym
                    if (_events[date] != null &&
                        _events[date].toString() != "[]" &&
                        _checkIfEventIsPaidCalendar(
                            _events[date], _eventsModelList))
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Theme.of(context).indicatorColor,
                                borderRadius: BorderRadius.circular(1.0)),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          if (_events[date].length > 0)
                            Text(
                              _getEmployerShortName(
                                  _events[date][0], _eventsModelList),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                        ],
                      ),
                    //jesli eventy sa i chociaz jeden jest nie oplacony buduje dzien czerwony
                    if (_events[date] != null &&
                        _events[date].toString() != "[]" &&
                        !_checkIfEventIsPaidCalendar(
                            _events[date], _eventsModelList))
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Theme.of(context).errorColor,
                                borderRadius: BorderRadius.circular(1.0)),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          if (_events[date].length > 0)
                            Text(
                              _getEmployerShortName(
                                  _events[date][0], _eventsModelList),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              //************************************************************************************************** */
              //dzien dzisiejszy
              todayDayBuilder: (context, date, events) => Container(
                margin: const EdgeInsets.all(0.5),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 2, color: Theme.of(context).backgroundColor),
                    borderRadius: BorderRadius.circular(2.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    //*********************************** */
                    //Warunki sprawdzajace czy dany event jest oplacony calkowicie czy nie
                    //jesli nie ma eventow buduje normalny dzien
                    if (_events[date] == null ||
                        _events[date].toString() ==
                            "[]") //sprawdzenie czy event z dzisiaj zawiera jakies elementy
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Theme.of(context).selectedRowColor,
                                borderRadius: BorderRadius.circular(1.0)),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                        ],
                      ),

                    //jesli sa eventy i wszystkie sa zaplacone u pracodawcow buduje dzien z kolorem zielonym
                    if (_events[date] != null &&
                        _events[date].toString() != "[]" &&
                        _checkIfEventIsPaidCalendar(
                            _events[date], _eventsModelList))
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Theme.of(context).indicatorColor,
                                borderRadius: BorderRadius.circular(1.0)),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          if (_events[date].length > 0)
                            Text(
                              _getEmployerShortName(
                                  _events[date][0], _eventsModelList),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                        ],
                      ),
                    //jesli eventy sa i chociaz jeden jest nie oplacony buduje dzien czerwony
                    if (_events[date] != null &&
                        _events[date].toString() != "[]" &&
                        !_checkIfEventIsPaidCalendar(
                            _events[date], _eventsModelList))
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Theme.of(context).errorColor,
                                borderRadius: BorderRadius.circular(1.0)),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          if (_events[date].length > 0)
                            Text(
                              _getEmployerShortName(
                                  _events[date][0], _eventsModelList),
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            calendarController: _controller,
          ),
          //przycisk odpowiedzialny za dodawanie nowego eventu
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).backgroundColor),
                  ),
                  onPressed: () {
                    _employerNameValue = null;
                    choosenWorkers = [];
                    _showDialogAddEvent();
                    _createNameList();
                  },
                  child: Text(
                    "Dodaj",
                    style: TextStyle(
                      color: Theme.of(context).hoverColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            ],
          ),
          //event wyswietlany pod kalendarzem jako lista
          ..._selectedEvents.map(
            (event) => Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: Container(
                  color: Theme.of(context).selectedRowColor,
                  child: ListTile(
                    leading: Container(
                      width: 5,
                      child: Icon(
                        Icons.arrow_right,
                        color: Theme.of(context).hintColor,
                        size: 60,
                      ),
                    ),
                    title: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            event,
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: 16,
                            ),
                          ),
                          //icona zmienia kolor w zaleznosci od statusu eventu
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                            child: Column(
                              children: [
                                Text(
                                  "Rozliczenie:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.business_center,
                                      color: _checkIfEventIsPaidEmployer(
                                              event, this._eventsModelList)
                                          ? Theme.of(context).indicatorColor
                                          : Theme.of(context).errorColor,
                                      size: 50,
                                    ),
                                    Icon(
                                      Icons.people,
                                      color: _checkIfEventIsPaidWorker(
                                              event, this._eventsModelList)
                                          ? Theme.of(context).indicatorColor
                                          : Theme.of(context).errorColor,
                                      size: 50,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                  child: IconSlideAction(
                    caption: 'Usuń',
                    color: Theme.of(context).errorColor,
                    icon: Icons.delete,
                    onTap: () {
                      deleteEvent(event);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                  child: IconSlideAction(
                    caption: 'Szczeguły',
                    color: Theme.of(context).backgroundColor,
                    icon: Icons.assessment,
                    onTap: () => _navigateToEventDetail(event),
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

//okienko wyświetlające się przy dodawaniu nowego eventu
  void _showDialogAddEvent() {
    String summary = "";
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).selectedRowColor,
            content: Container(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    //Tutaj wybieramy z listy u kogo pracujemy
                    DropdownButton<String>(
                      hint: Text(
                        "Wybierz pracodawcę",
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      value: _employerNameValue,
                      isDense: true,
                      onChanged: (newValue) {
                        setState(() {
                          _employerNameValue = newValue;
                          choosenEmployerName = employersNameList[
                              _choosenNameNumberEmployer(_employerNameValue)];
                        });
                      },
                      items: employersNameList.map((var value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    //napisy rozpoczecia i zakonczenia czasu pracy oraz TimePickery do wyboru godzin
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                "Godz. rozp.",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).hintColor),
                              ),
                              Text(
                                "Godz. zak.",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).hintColor),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                  left: BorderSide(
                                      width: 1.0,
                                      color: Theme.of(context).hintColor),
                                )),
                                child: TimeWorkStart()),
                            Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                  left: BorderSide(
                                      width: 1.0,
                                      color: Theme.of(context).hintColor),
                                )),
                                child: TimeWorkStop()),
                          ],
                        ),
                      ],
                    ),
                    //picker do wyboru czusu przerwy
                    Container(child: BreakTime()),
                    //widget dodawania pracowników
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).backgroundColor),
                      ),
                      onPressed: () {
                        setState(() {
                          //wyswietlenie okienka z wyborem pracownikow
                          _showAddWorker();
                        });
                      },
                      child: Text(
                        "Dodaj Pracownika",
                        style: TextStyle(
                          color: Theme.of(context).hoverColor,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    //Przycisk wyświetlający podsumowanie danych w evencie
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).backgroundColor),
                      ),
                      onPressed: () {
                        setState(() {
                          //wyświetlenie podsumowanie jako tekst z danymi
                          summary = "Data zdarzenia: " +
                              _dateGenerator(_controller.selectedDay) +
                              "\nPracodawca: " +
                              _employerNameValue.toString() +
                              "\nPracowali: " +
                              choosenWorkers.join("; ") +
                              "\nCzas pracy: " +
                              timeStart.toString() +
                              " - " +
                              timeStop.toString() +
                              "\nPrzepracowano godzin: " +
                              _workTimeCounter(workStart, workStop, timeBreak) +
                              "\nCzas przerwy: " +
                              timeBreak.toString();
                        });
                      },
                      child: Text(
                        "Podsumowanie",
                        style: TextStyle(
                          color: Theme.of(context).hoverColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    //Wyświetlenie wprowadzanych danych
                    Text(
                      summary,
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                    //Przyciski anulowania i akceptacji zapisu eventu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).backgroundColor),
                          ),
                          onPressed: () {
                            //Sprawdzenie poprawności danych oraz dodanie nowego eventu do listy z danego dnia
                            if (_employerNameValue != null &&
                                !_workTimeCounter(
                                        workStart, workStop, timeBreak)
                                    .contains("błąd") &&
                                choosenWorkers.length != 0 &&
                                summary != "") {
                              //utworzenie tytulu eventu
                              _titleCreated = _titleGenerator(
                                  _selectedEvents.length + 1,
                                  _dateGenerator(_controller.selectedDay),
                                  _employerNameValue.toString(),
                                  choosenWorkers,
                                  timeStart.toString(),
                                  timeStop.toString());
                              if (_events[_controller.selectedDay] != null) {
                                _events[_controller.selectedDay]
                                    .add(_titleCreated);
                              } else {
                                _events[_controller.selectedDay] = [
                                  _titleCreated
                                ];
                              }
                              //zapisanie danych do shared Preference i do bazy danych
                              _prefs.setString(
                                  "events", json.encode(_encodeMap(_events)));
                              //zapis eventu do bazy
                              int choosenWorkersLenght = choosenWorkers.length;
                              _createEventDB(
                                  _titleCreated,
                                  _dateGenerator(_controller.selectedDay),
                                  timeStart.toString() +
                                      " - " +
                                      timeStop.toString(),
                                  _employerNameValue.toString(),
                                  choosenWorkers.join("; "),
                                  choosenWorkersLenght,
                                  _controller.selectedDay.weekday,
                                  timeBreak,
                                  double.tryParse(_workTimeCounter(
                                      workStart, workStop, timeBreak)));
                              _updateListViewEvents();
                              _selectedEvents =
                                  _events[_controller.selectedDay];
                              Navigator.pop(context);
                            } else {
                              _showDialog("Błąd",
                                  "Nie udało się zapisać dnia pracy\nNie pełne dane\nLub nie użyto Podsumowania");
                            }
                          },
                          child: Text(
                            "Zapisz",
                            style: TextStyle(
                              color: Theme.of(context).hoverColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).backgroundColor),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Anuluj",
                            style: TextStyle(
                              color: Theme.of(context).hoverColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  //wyswietlenie listy pracownikow
  _showAddWorker() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
            backgroundColor: Theme.of(context).selectedRowColor,
            title: Text(
              "Wybierz kto pracował:",
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
            content: MultiSelectChip(
              workersShortNameList,
              onSelectionChanged: (selectedList) {
                setState(() {
                  choosenWorkers = selectedList;
                });
              },
            ),
            actions: <Widget>[
              TextButton(
                  child: Text("OK",
                      style: TextStyle(
                          fontSize: 18, color: Theme.of(context).hintColor)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

//funkcja obliczajaca czas pracy
  String _workTimeCounter(var startTime, var stopTime, var breakTime) {
    if (startTime == null) {
      return "0";
    }
    var timeWork = stopTime.difference(startTime);
    var p = timeWork.toString();
    var hours = double.parse(p.split(":")[0]);
    var minutes = double.parse(p.split(":")[1]);
    double time = (hours + (minutes / 60)) - (breakTime / 60);
    if (startTime.hour == stopTime.hour &&
        startTime.minute > stopTime.minute &&
        time > 0) {
      time *= -1;
    }
    if (time <= 0) {
      return "błąd";
    } else {
      timeWorkSum = time;
      return time.toStringAsFixed(2);
    }
  }

  //funkcja generująca napis z wybraną datą
  String _dateGenerator(var data) {
    String dayy, month;
    if (data.day < 10) {
      dayy = "0" + data.day.toString();
    } else {
      dayy = data.day.toString();
    }
    if (data.month < 10) {
      month = "0" + data.month.toString();
    } else {
      month = data.month.toString();
    }
    return dayy.toString() +
        "-" +
        month.toString() +
        "-" +
        data.year.toString();
  }

//funkcja generujaca tytul potrzebny do shared preferenced
  String _titleGenerator(int number, String date, String employerName,
      List workerksList, String timeStartLocal, String timeStopLocal) {
    return number.toString() +
        ". Data: " +
        date +
        "\nPraca u: " +
        employerName +
        "\nPracował/li: " +
        workerksList.join("; ") +
        "\nOd: " +
        timeStartLocal +
        " Do: " +
        timeStopLocal +
        "\n-----------------------------------";
  }

//funkcja tworząca event do bazy danych
  Future<void> _createEventDB(
      String title,
      String date,
      String workTime,
      String employers,
      String workersPaid,
      int workersNumber,
      int dayNumber,
      int breakTime,
      double hourSum) async {
    eventsModel = EventsModel(title, date, workTime, employers, workersPaid, "",
        workersNumber, dayNumber, breakTime, hourSum, 0);
    int result;
    result = await eventHelper.insertEvent(eventsModel);
    if (result != 0) {
      _showDialog('Status', 'Dodano Event');
    } else {
      _showDialog('Status', 'Nie udało się dodać Eventu');
    }
  }

  //usuwanie eventu z SP ora DB
  void deleteEvent(var event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).selectedRowColor,
        content: Container(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Napewno usunąć zdarzenie?",
                style:
                    TextStyle(fontSize: 20, color: Theme.of(context).hintColor),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).backgroundColor),
                    ),
                    onPressed: () {
                      //usunięcie danych z shared preferenced
                      this._events[_controller.selectedDay].remove(event);
                      _prefs.setString(
                          "events", json.encode(_encodeMap(_events)));
                      //usuwanie danych z bazy
                      eventHelper.deleteEvent(event);
                      _initPrefs();
                      _updateListViewEvents();
                      _selectedEvents = _events[_controller.selectedDay];
                      Navigator.pop(context);
                      return;
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Theme.of(context).hoverColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).backgroundColor),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      return;
                    },
                    child: Text(
                      "Anuluj",
                      style: TextStyle(
                        color: Theme.of(context).hoverColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  //nawigowanie do strony z detalami Eventu, utworzenie nowego eventu z tytulem, przekazanie modelu eventu oraz listy pracownikow
  void _navigateToEventDetail(String title) async {
    EventsModel modelTaked;
    _eventsModelList.forEach((element) {
      if (element.title == title) modelTaked = element;
    });
    List workersList = [];
    if (modelTaked.workersPaid != "" && modelTaked.workersNotPaid != "") {
      workersList = modelTaked.workersNotPaid.split("; ") +
          modelTaked.workersPaid.split("; ");
    } else if (modelTaked.workersPaid == "") {
      workersList = modelTaked.workersNotPaid.split("; ");
    } else if (modelTaked.workersNotPaid == "") {
      workersList = modelTaked.workersPaid.split("; ");
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EventDetailScreen(modelTaked, workersList);
        },
      ),
    );
  }

  void _showDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      backgroundColor: Theme.of(context).selectedRowColor,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).hintColor),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).hintColor),
      ),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  //Kolorowanie eventow
  //****************************************/

//funkcja sprawdzajaca czy w dany event jest oplacony
  bool _checkIfEventIsPaidEmployer(String title, List<EventsModel> eventList) {
    bool check = false;
    if (eventList != null) {
      eventList.forEach((element) {
        if (element.title == title && element.isPaid == 1) check = true;
      });
    }
    return check;
  }

  //funkcja zwracajaca krotka nazwe pracodawcy
  String _getEmployerShortName(String title, List<EventsModel> eventList) {
    String name = "";
    String shortname = "";
    if (eventList != null) {
      eventList.forEach((element) {
        if (element.title == title) name = element.employer;
      });
      //pobranie z listy pracodawcow krotkiego imienia
      if (_employersModelList != null) {
        _employersModelList.forEach((element) {
          if (element.name == name) shortname = element.shortName;
        });
      }
    }
    return shortname;
  }

  //funkcja sprawdzajaca czy w dany event jest oplacony
  bool _checkIfEventIsPaidWorker(String title, List<EventsModel> eventList) {
    bool check = false;
    if (eventList != null) {
      eventList.forEach((element) {
        if (element.title == title && element.workersNotPaid.isEmpty)
          check = true;
      });
    }
    return check;
  }

//sprawdzenie dla listy eventow dla kalendarza
  bool _checkIfEventIsPaidCalendar(
      List<dynamic> list, List<EventsModel> eventList) {
    bool check = true;
    if (list != null && eventList != null) {
      eventList.forEach((element) {
        list.forEach((elementList) {
          if (element.title == elementList &&
              (element.isPaid == 0 ||
                  element.workersNotPaid !=
                      "")) //sprawdzanie czy event jest oplacony
            check = false;
        });
      });
    }
    return check;
  }
}
