//druga strona do dodawania pracownika

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:working_time_management/helpers/eventHelper.dart';
import 'package:working_time_management/helpers/workersHelper.dart';
import 'package:working_time_management/models/workersModel.dart';

class WorkersDetail extends StatefulWidget {
  final String title;
  final WorkersModel workersModel;
  final int position;

  WorkersDetail(this.workersModel, this.title, this.position);

  @override
  _WorkersDetailState createState() {
    return _WorkersDetailState(this.workersModel, this.title, this.position);
  }
}

class _WorkersDetailState extends State<WorkersDetail> {
  WorkersModel workersModel;
  String title;
  int position;
  WorkersHelper workersHelper = WorkersHelper();
  EventHelper eventHelper = EventHelper();
  List<WorkersModel> workersModelList;
  List<String> additionsList = [];
  double hoursSum = 0;
  List listOfSum;
  String rate;
  String titleToCheck;
  String amount;
  TextEditingController _hoursRateController = TextEditingController();
  TextEditingController _titleToCheckController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _notesController = TextEditingController();
  double receivable = 0;
  RegExp re = RegExp(r'^(\-?\d+)?$');

  _WorkersDetailState(this.workersModel, this.title, this.position);

  @override
  void initState() {
    rate = "0";
    receivable = 0;
    updateListView();
    if (workersModel.additions.toString() != "") {
      additionsList = workersModel.additions.split("_;");
    } else {
      additionsList = [];
    }
    _notesController.text = workersModel.notes;
    getHourSum(workersModel.shortName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _showDialog(String title, String message) {
      AlertDialog alertDialog = AlertDialog(
        title: Text(title),
        content: Text(message),
      );
      showDialog(context: context, builder: (_) => alertDialog);
    }

    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back,
                color: Theme.of(context).selectedRowColor),
            onPressed: () {
              updateListView();
              Navigator.of(context).pop();
            }),
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Text(
                      workersModel.name,
                      style: TextStyle(
                          fontSize: 25, color: Theme.of(context).accentColor),
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: Text(
                      "Łącznie przepracowano: " +
                          hoursSum.toString() +
                          " godzin/y.",
                      style: TextStyle(
                          fontSize: 18, color: Theme.of(context).accentColor),
                    ),
                  ),
                ],
              ),
              //Ustawienie i wyswietlenie sumy za godzine
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Stawka za godzine:",
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).accentColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 30, 12),
                    child: Container(
                      width: 88,
                      height: 40,
                      child: TextField(
                        onChanged: (value) {
                          rate = value;
                        },
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).accentColor,
                        ),
                        textAlign: TextAlign.center,
                        controller: _hoursRateController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ),
              //wyswielenie dodatkow z bazy danych w postaci listy
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Dodatki finansowe:",
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).accentColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      child: Text(
                        "Dodaj",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      onPressed: () {
                        _showAdditionAdd();
                        //utworzenie listy
                      },
                    ),
                  )
                ],
              ),
              //lista dodatokow, zaliczek itp
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(
                              color: Theme.of(context).accentColor,
                              width: 2.0))),
                  height: 150,
                  child: getList(),
                ),
              ),

              //podsumowanie godzin pracy
              RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  "Podsumowanie",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onPressed: () {
                  setState(() {
                    //zsumowanie dodatkow za prace
                    if (double.parse(rate) > 0) {
                      //pobranie sumy wartosci z listy dodatkow
                      double suma = 0;
                      for (int i = 0; i < additionsList.length; i++) {
                        suma += double.parse(
                            additionsList[i].split("(")[1].split(")")[0]);
                      }
                      receivable = hoursSum * double.parse(rate) + suma;
                    } else {
                      _showDialog("Błąd", "Nie podano stawki za godzinę!");
                    }
                  });
                },
              ),

              //wyswietlenie wyniku przepracowanych godzin
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: Text(
                      "Suma wypłaty: " + receivable.toString(),
                      style: TextStyle(
                          fontSize: 22, color: Theme.of(context).accentColor),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: Text(
                      "Notatki:",
                      style: TextStyle(
                          fontSize: 18, color: Theme.of(context).accentColor),
                    ),
                  ),
                ],
              ),
//kontener na notatki
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextField(
                    controller: _notesController,
                    minLines: 2,
                    maxLines: 30,
                    autocorrect: false,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).selectedRowColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    onChanged: (value) {},
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 40, 0),
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      child: Text(
                        "Zapisz",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      onPressed: () {
                        workersHelper.updateNotes(
                            _notesController.text, workersModel.shortName);
                        _notesController.text = _notesController.text;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

//wyswietlenie listy dodatkow
  ListView getList() {
    return ListView.builder(
        itemCount: additionsList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 40,
            child: ListTile(
              title: GestureDetector(
                onLongPress: () {
                  //usuwanie danej listy
                  deleteNote(additionsList[index]);
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(
                              color: Theme.of(context).accentColor,
                              width: 2.0))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: Text(
                      additionsList[index],
                      style: TextStyle(
                          fontSize: 18, color: Theme.of(context).accentColor),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

//metoda usuwajaca z listy wybrany element a nastepnie zapisujaca do bazy danych
  deleteNote(String stringToDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Napewno usunąć wpis?",
                style: TextStyle(fontSize: 20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new RaisedButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      //usuniecie wpisu z listy
                      additionsList.remove(stringToDelete);
                      //zapisanie listy do bazy danych
                      String textList = additionsList.join("_;");
                      workersHelper.updateAdditions(
                          textList, workersModel.shortName);
                      updateListView();
                      Navigator.pop(context);
                      return;
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  RaisedButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      Navigator.pop(context);
                      return;
                    },
                    child: Text(
                      "Anuluj",
                      style: TextStyle(
                        color: Colors.black,
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

//metoda sluzaca do dodania wpisu o dodatkach, zaliczkach, mieszkaniu itp
  _showAdditionAdd() {
    //wyswietlanie dialogu dla uzytkownika
    _showDialog(String title, String message) {
      AlertDialog alertDialog = AlertDialog(
        title: Text(title),
        content: Text(message),
      );
      showDialog(context: context, builder: (_) => alertDialog);
    }

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              content: Container(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Tytuł dodatku:",
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).accentColor),
                          ),
                        ],
                      ),
                      TextField(
                        onChanged: (value) {
                          titleToCheck = value;
                        },
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).accentColor,
                        ),
                        textAlign: TextAlign.center,
                        controller: _titleToCheckController,
                        keyboardType: TextInputType.text,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Kwota:",
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).accentColor),
                          ),
                          Container(
                            width: 120,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                              child: TextField(
                                onChanged: (value) {
                                  amount = value;
                                },
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).accentColor,
                                ),
                                textAlign: TextAlign.center,
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            RaisedButton(
                              color: Theme.of(context).accentColor,
                              onPressed: () {
                                //dodawanie do bazy danych wpisu o dodatkach
                                if (re.hasMatch(amount) &&
                                    (!titleToCheck.contains("(") &&
                                        !titleToCheck.contains(")"))) {
                                  String napis =
                                      titleToCheck + ":  (" + amount + ")";
                                  additionsList.add(napis);
                                  //zapisanie listy do bazy danych
                                  String textaddition =
                                      additionsList.join("_;");
                                  updateListView();
                                  workersHelper.updateAdditions(
                                      textaddition, workersModel.shortName);
                                  _amountController.text = "";
                                  _titleToCheckController.text = "";
                                  Navigator.pop(context);
                                  return;
                                } else {
                                  _showDialog("Błąd",
                                      "Podano nie właściwe dane\nNie używaj znaków specjalnych np. (");
                                }
                              },
                              child: Text(
                                "OK",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            RaisedButton(
                              color: Theme.of(context).accentColor,
                              onPressed: () {
                                Navigator.pop(context);
                                return;
                              },
                              child: Text(
                                "Anuluj",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  //Pobieranie sumy godzin z Eventow oraz zliczanie ich w sume
  void getHourSum(String name) async {
    this.listOfSum = await eventHelper.getHourWorkerSum(name);
    this.listOfSum.forEach((element) {
      this.hoursSum += element['hourSum'];
    });
  }

  //dodawanie rekordow do bazy
  void updateListView() {
    final Future<Database> dbFuture = workersHelper.initialDatabase();
    dbFuture.then((databse) {
      Future<List<WorkersModel>> workersListFuture =
          workersHelper.getWorkersList();
      workersListFuture.then((workersModelList) {
        setState(() {
          this.workersModelList = workersModelList;
        });
      });
    });
  }
}
