import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:working_time_management/Calendar/widgets.dart';
import 'package:working_time_management/helpers/employersHelper.dart';
import 'package:working_time_management/helpers/workersHelper.dart';
import 'package:working_time_management/models/employersModel.dart';
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
  SharedPreferences prefs;
  String employerNameValue;
  String choosenEmployerName;

  //PRACODAWCY i PRACOWNICY
  //dane pracodawców
  EmployersHelper employersHelper = EmployersHelper();
  List<EmployersModel> employersModelList;
  int employersLenght = 0;

  //dane pracowników
  WorkersHelper workersHelper = WorkersHelper();
  List<WorkersModel> workersModelList;
  int workersLenght = 0;

  //pobieranie listy modeli pracodawców
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

  //pobieranie listy modeli pracodawców
  void updateListViewWorkers() {
    final Future<Database> dbFuture = workersHelper.initialDatabase();
    dbFuture.then((databse) {
      Future<List<WorkersModel>> workersModelListFuture =
          workersHelper.getWorkersList();
      workersModelListFuture.then((workersModelList) {
        setState(() {
          this.workersModelList = workersModelList;
          this.workersLenght = workersModelList.length;
        });
      });
    });
  }

  //metoda tworzaca liste imion Pracodawcow z bazy danych
  createNameList() {
    employersNameList = [];
    workersShortNameList = [];
    for (int i = 0; i < employersLenght; i++) {
      employersNameList.add(this.employersModelList[i].name);
    }
    for (int i = 0; i < workersLenght; i++) {
      workersShortNameList.add(this.workersModelList[i].shortName);
    }
  }

  //pobranie wybranego numeru wg imion
  int choosenNameNumberEmployer(String name) {
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

  @override
  Widget build(BuildContext context) {
    updateListViewEmployers();
    updateListViewWorkers();
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
                  employerNameValue = null;
                  choosenWorkers = [];
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
                      value: employerNameValue,
                      isDense: true,
                      onChanged: (newValue) {
                        setState(() {
                          employerNameValue = newValue;
                          choosenEmployerName = employersNameList[
                              choosenNameNumberEmployer(employerNameValue)];
                        });
                      },
                      items: employersNameList.map((var value) {
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
                    //picker do wyboru czusu przerwy
                    Container(child: BreakTime()),
                    //widget dodawania pracowników
                    OutlineButton(
                      borderSide: BorderSide(
                        color: Theme.of(context).accentColor,
                        width: 3,
                      ),
                      shape: StadiumBorder(),
                      child: Text(
                        "Dodaj Pracownika",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          //wyswietlenie okienka z wyborem pracownikow
                          showAddWorker();
                        });
                      },
                    ),

                    //Testowe texty do sprawdzania poprawnosci danych
                    //tytul będzie zapisywany do sharedPreferenced jako nawigacja do sczegółów eventu
                    Text(titleGenerator(
                        dateGenerator(_controller.selectedDay),
                        employerNameValue.toString(),
                        choosenWorkers,
                        timeStart.toString(),
                        timeStop.toString())),
                    Text("\nPracodawca: " + employerNameValue.toString()),
                    Text("Data zdarzenia: " +
                        dateGenerator(_controller.selectedDay)),
                    Text("Czas rozpoczęcia: " + timeStart.toString()),
                    Text("Czas zakończenia: " + timeStop.toString()),
                    Text("Czas przerwy: " + timeBreak.toString()),
                    Text("Przepracowano godzin: " +
                        workTimeCounter(workStart, workStop, timeBreak)),
                    Text("Pracowali: " + choosenWorkers.join("; ")),
                    //Przyciski anulowania i akceptacji zapisu eventu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        OutlineButton(
                          borderSide: BorderSide(color: Colors.blue, width: 3),
                          shape: StadiumBorder(),
                          child: Text(
                            "Zapisz",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () {
                            //zapisanie danych do shared Preference i do bazy danych
                            //Sprawdenie poprawności danych
                            if (employerNameValue != null &&
                                !workTimeCounter(workStart, workStop, timeBreak)
                                    .contains("błąd") &&
                                choosenWorkers.length != 0) {
                              if (_events[_controller.selectedDay] != null) {
                                _events[_controller.selectedDay].add(
                                    titleGenerator(
                                        dateGenerator(_controller.selectedDay),
                                        employerNameValue.toString(),
                                        choosenWorkers,
                                        timeStart.toString(),
                                        timeStop.toString()));
                              } else {
                                _events[_controller.selectedDay] = [
                                  titleGenerator(
                                      dateGenerator(_controller.selectedDay),
                                      employerNameValue.toString(),
                                      choosenWorkers,
                                      timeStart.toString(),
                                      timeStop.toString())
                                ];
                              }
                            } else {
                              showMessageToUser("Błąd",
                                  "Nie udało się zapisać dnia pracy\nNie pełne dane.");
                            }
                            Navigator.pop(context);
                          },
                        ),
                        OutlineButton(
                          borderSide: BorderSide(color: Colors.blue, width: 3),
                          shape: StadiumBorder(),
                          child: Text(
                            "Anuluj",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
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
  showAddWorker() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
            backgroundColor: Theme.of(context).canvasColor,
            title: Text("Wybierz kto pracował:"),
            content: MultiSelectChip(
              workersShortNameList,
              onSelectionChanged: (selectedList) {
                setState(() {
                  choosenWorkers = selectedList;
                });
              },
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text("OK", style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

//funkcja obliczajaca czas pracy
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

  //funkcja generująca napis z wybraną datą
  String dateGenerator(var data) {
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
        ":" +
        month.toString() +
        ":" +
        data.year.toString();
  }

//funkcja generujaca tytul potrzebny do shared preferenced
  String titleGenerator(String date, String employerName, List workerksList,
      String timeStartLocal, String timeStopLocal) {
    return "Data: " +
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

//Funkcja wyswietlajaca informacje dla użytkownika
  void showMessageToUser(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
