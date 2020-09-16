import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:working_time_management/Calendar/widgets.dart';
import 'package:working_time_management/helpers/employersHelper.dart';
import 'package:working_time_management/models/employersModel.dart';

import '../globals.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarController _controller;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  SharedPreferences prefs;
  String dropdownValue;
  String choosenEmployerName;

  //dane pracodawców
  EmployersHelper employersHelper = EmployersHelper();
  List<EmployersModel> employersModelList;
  int employersLenght = 0;
  List<String> nameList;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _events = {};
    _selectedEvents = [];
    initPrefs();
  }
  //PREFERENCJE

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          decodeMap(json.decode(prefs.getString("events") ?? "{}")));
    });
  }

  //metoda ladujaca event do share-preference
  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  //metoda pobierajaca z share event
  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }

  //PRACODAWCY

  //pobieranie listy modeli
  void updateListViewEmployers() {
    final Future<Database> dbFuture = employersHelper.initialDatabase();
    dbFuture.then((databse) {
      Future<List<EmployersModel>> employersModelListFuture =
          employersHelper.getEmployersList();
      employersModelListFuture.then((employersModelList) {
        setState(() {
          this.employersModelList = employersModelList;
          this.employersLenght = employersModelList.length;
        });
      });
    });
  }

  //metoda tworzaca liste imion Pracodawcow z bazy danych
  createNameList() {
    nameList = [];
    for (int i = 0; i < employersLenght; i++) {
      nameList.add(this.employersModelList[i].name);
    }
  }

  //pobranie wybranego numeru wg imion
  int choosenNameNumber(String name) {
    return nameList.indexOf(name);
  }

  @override
  Widget build(BuildContext context) {
    updateListViewEmployers();
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TableCalendar(
            locale: 'pl_PL',
            events: _events,
            initialCalendarFormat: CalendarFormat.month,
            calendarStyle: CalendarStyle(
                canEventMarkersOverflow: true,
                todayColor: Theme.of(context).cardColor,
                selectedColor: Theme.of(context).accentColor,
                todayStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.white)),
            headerStyle: HeaderStyle(
              centerHeaderTitle: false,
              formatButtonDecoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              formatButtonTextStyle: TextStyle(color: Colors.white),
              formatButtonShowsNext: false,
            ),
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: (date, events) {
              //zdarzenie po kliknieciu w dzien
              setState(() {
                _selectedEvents = events;
              });
            },
            //budowanie dni kalendarza
            builders: CalendarBuilders(
              dayBuilder: (context, date, events) => Container(
                margin: const EdgeInsets.all(0.5),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 15,
                      alignment: Alignment.center,
                      width: 20,
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              selectedDayBuilder: (context, date, events) => Container(
                margin: const EdgeInsets.all(0.5),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 15,
                      alignment: Alignment.center,
                      width: 20,
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              todayDayBuilder: (context, date, events) => Container(
                margin: const EdgeInsets.all(0.5),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 15,
                      alignment: Alignment.center,
                      width: 20,
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            calendarController: _controller,
          ),
          //event wyswietlany pod kalendarzem
          ..._selectedEvents.map((event) => GestureDetector(
                onLongPress: () {},
                child: ListTile(
                  title: Text(
                    event,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              )),
          //przycisk odpowiedzialny za dodawanie nowego eventu
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              RaisedButton(
                color: Theme.of(context).accentColor,
                onPressed: () {
                  dropdownValue = null;
                  _showDialogAddEvent();
                  createNameList();
                },
                child: Text(
                  "Dodaj",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              )
            ],
          )
        ],
      )),
    );
  }

//okienko wyświetlające się przy dodawaniu nowego eventu
  void _showDialogAddEvent() async {
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
                      hint: Text("Wybierz pracodawcę"),
                      value: dropdownValue,
                      isDense: true,
                      onChanged: (newValue) {
                        setState(() {
                          dropdownValue = newValue;
                          choosenEmployerName =
                              nameList[choosenNameNumber(dropdownValue)];
                        });
                      },
                      items: nameList.map((var value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    //napisy rozpoczecia i zakonczenia timeu pracy oraz TimePickery do wyboru godzin
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                "Godz. rozp.",
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                "Godz. zak.",
                                style: TextStyle(fontSize: 16),
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
                                      width: 1.0, color: Colors.black),
                                )),
                                child: TimeWorkStart()),
                            Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                  left: BorderSide(
                                      width: 1.0, color: Colors.black),
                                )),
                                child: TimeWorkStop()),
                          ],
                        ),
                      ],
                    ),
                    //picker do wyboru timeu przerwy
                    Container(child: BreakTime()),
                    Text(timeStart.toString()),
                    Text(timeStop.toString()),
                    Text(timeBreak.toString()),
                    Text(workTimeCounter(workStart, workStop,
                        timeBreak)), //tak pobieram czas pracy do bazy danych
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

//funkcja obliczajaca time pracy
  String workTimeCounter(var startTime, var stopTime, var breakTime) {
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
}
