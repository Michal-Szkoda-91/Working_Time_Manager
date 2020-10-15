//druga strona do dodawania pracownika

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:working_time_management/Employers/employersArchives.dart';
import 'package:working_time_management/Employers/employersShortcut.dart';
import 'package:working_time_management/helpers/employersHelper.dart';
import 'package:working_time_management/helpers/eventHelper.dart';
import 'package:working_time_management/models/employersModel.dart';
import 'package:working_time_management/models/eventsModel.dart';

class EmployersDetail extends StatefulWidget {
  final String title;
  final EmployersModel employersModel;
  final int position;

  EmployersDetail(this.employersModel, this.title, this.position);

  @override
  _EmployersDetailState createState() {
    return _EmployersDetailState(
        this.employersModel, this.title, this.position);
  }
}

class _EmployersDetailState extends State<EmployersDetail> {
  EmployersModel employersModel;
  String title;
  int position;
  double additionsSum;
  EmployersHelper employersHelper = EmployersHelper();
  EventHelper eventHelper = EventHelper();
  List<EventsModel> eventsModelList = new List();
  List<EmployersModel> employersModelList;
  List<String> additionsList;
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

  _EmployersDetailState(this.employersModel, this.title, this.position);

  @override
  void initState() {
    hoursSum = 0;
    rate = "0";
    receivable = 0;
    updateListView();
    if (employersModel.additions.toString() != "") {
      additionsList = employersModel.additions.split("_;");
    } else {
      additionsList = [];
    }
    _notesController.text = employersModel.notes;
    getHourSum(employersModel.name);
    eventHelper.getHourEmployerSum(employersModel.name).then((event) {
      setState(() {
        event.forEach((element) {
          eventsModelList.add(EventsModel.fromMapObject(element));
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _showDialog(String title, String message) {
      AlertDialog alertDialog = AlertDialog(
        backgroundColor: Theme.of(context).selectedRowColor,
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).textSelectionColor,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).textSelectionColor,
          ),
        ),
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
              Navigator.pop(context, true);
            }),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).hoverColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    employersModel.name,
                    style: TextStyle(
                        fontSize: 25,
                        color: Theme.of(context).textSelectionColor),
                  ),
                ],
              ),
              //przyciski kierujące na storny z archiwum i skrótu dla pracodawcy
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      child: Text(
                        "Skrót",
                        style: TextStyle(
                            color: Theme.of(context).hoverColor, fontSize: 18),
                      ),
                      onPressed: () {
                        setState(() {
                          //zsumowanie dodatkow za prace
                          if (double.parse(rate) > 0) {
                            //pobranie sumy wartosci z listy dodatkow
                            additionsSum = 0;
                            for (int i = 0; i < additionsList.length; i++) {
                              additionsSum += double.parse(
                                  additionsList[i].split("(")[1].split(")")[0]);
                            }
                            receivable =
                                hoursSum * double.parse(rate) + additionsSum;
                            //przejscie do strony ze skrotami do wyswietlenia dla inwestora
                            navigateToEmployerShortcut(
                                employersModel.name,
                                hoursSum.toString() +
                                    " * " +
                                    rate.toString() +
                                    " + " +
                                    additionsSum.toString() +
                                    " = " +
                                    receivable.toString(),
                                additionsList);
                          } else {
                            _showDialog(
                                "Błąd", "Nie podano stawki za godzinę!");
                          }
                        });
                      },
                    ),
                  ),
                  RaisedButton(
                    color: Theme.of(context).accentColor,
                    child: Text(
                      "Archiwum",
                      style: TextStyle(
                          color: Theme.of(context).hoverColor, fontSize: 18),
                    ),
                    onPressed: () {
                      navigateToEmployerArchives(employersModel.name);
                    },
                  ),
                  RaisedButton(
                    color: Theme.of(context).accentColor,
                    child: Text(
                      "Zapłacono",
                      style: TextStyle(
                          color: Theme.of(context).hoverColor, fontSize: 18),
                    ),
                    onPressed: () {
                      payForAll();
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: Text(
                      "Łącznie przepracowano: " +
                          hoursSum.toString() +
                          " godzin/y.",
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textSelectionColor),
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
                        fontSize: 18,
                        color: Theme.of(context).textSelectionColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 30, 12),
                    child: Container(
                      width: 88,
                      height: 40,
                      child: TextField(
                        cursorColor: Theme.of(context).textSelectionColor,
                        onChanged: (value) {
                          rate = value;
                        },
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textSelectionColor,
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
                        fontSize: 18,
                        color: Theme.of(context).textSelectionColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      child: Text(
                        "Dodaj",
                        style: TextStyle(
                            color: Theme.of(context).hoverColor, fontSize: 18),
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
                              color: Theme.of(context).textSelectionColor,
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
                  style: TextStyle(
                      color: Theme.of(context).hoverColor, fontSize: 18),
                ),
                onPressed: () {
                  setState(() {
                    //zsumowanie dodatkow za prace
                    if (double.parse(rate) > 0) {
                      //pobranie sumy wartosci z listy dodatkow
                      additionsSum = 0;
                      for (int i = 0; i < additionsList.length; i++) {
                        additionsSum += double.parse(
                            additionsList[i].split("(")[1].split(")")[0]);
                      }
                      receivable = hoursSum * double.parse(rate) + additionsSum;
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
                          fontSize: 22,
                          color: Theme.of(context).textSelectionColor),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: Text(
                      "Notatki:",
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textSelectionColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      child: Text(
                        "Zapisz",
                        style: TextStyle(
                            color: Theme.of(context).hoverColor, fontSize: 18),
                      ),
                      onPressed: () {
                        employersHelper.updateNotes(
                            _notesController.text, employersModel.shortName);
                        _notesController.text = _notesController.text;
                      },
                    ),
                  ),
                ],
              ),
//kontener na notatki
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextField(
                    style:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                    controller: _notesController,
                    minLines: 2,
                    maxLines: 30,
                    autocorrect: false,
                    cursorColor: Theme.of(context).textSelectionColor,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).selectedRowColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide:
                            BorderSide(color: Theme.of(context).cursorColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide:
                            BorderSide(color: Theme.of(context).cursorColor),
                      ),
                    ),
                    onChanged: (value) {},
                  ),
                ),
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
                  deletewpis(additionsList[index]);
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(
                              color: Theme.of(context).textSelectionColor,
                              width: 2.0))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: Text(
                      additionsList[index],
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textSelectionColor),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

//metoda usuwajaca z listy wybrany element a nastepnie zapisujaca do bazy danych
  deletewpis(String stringToDelete) {
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
                "Na pewno usunąć wpis?",
                style: TextStyle(
                    fontSize: 20, color: Theme.of(context).textSelectionColor),
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
                      employersHelper.updateAdditions(
                          textList, employersModel.name);
                      updateListView();
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
                  RaisedButton(
                    color: Theme.of(context).accentColor,
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

//metoda sluzaca do dodania wpisu o dodatkach, zaliczkach, mieszkaniu itp
  _showAdditionAdd() {
    //wyswietlanie dialogu dla uzytkownika
    _showDialog(String title, String message) {
      AlertDialog alertDialog = AlertDialog(
        backgroundColor: Theme.of(context).selectedRowColor,
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).textSelectionColor),
        ),
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).textSelectionColor),
        ),
      );
      showDialog(context: context, builder: (_) => alertDialog);
    }

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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Tytuł dodatku:",
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).textSelectionColor),
                          ),
                        ],
                      ),
                      TextField(
                        cursorColor: Theme.of(context).textSelectionColor,
                        onChanged: (value) {
                          titleToCheck = value;
                        },
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).textSelectionColor),
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
                                color: Theme.of(context).textSelectionColor),
                          ),
                          Container(
                            width: 120,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                              child: TextField(
                                cursorColor:
                                    Theme.of(context).textSelectionColor,
                                onChanged: (value) {
                                  amount = value;
                                },
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).textSelectionColor,
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
                                  employersHelper.updateAdditions(
                                      textaddition, employersModel.name);
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
                                  color: Theme.of(context).hoverColor,
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
                                  color: Theme.of(context).hoverColor,
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

  //Pobieranie sumy godzin z Eventow oraz zliczanie w jedna sume
  void getHourSum(String name) async {
    this.listOfSum = await eventHelper.getHourEmployerSum(name);
    this.listOfSum.forEach((element) {
      this.hoursSum = this.hoursSum +
          (element['hourSum'] *
              element[
                  'workersNumber']); //godziny sa mnozone przez ilosc pracownikow z danego dnia
    });
  }

  //dodawanie rekordow do bazy
  void updateListView() {
    final Future<Database> dbFuture = employersHelper.initialDatabase();
    dbFuture.then((databse) {
      Future<List<EmployersModel>> employersListFuture =
          employersHelper.getEmployersList();
      employersListFuture.then((employersModelList) {
        setState(() {
          this.employersModelList = employersModelList;
        });
      });
    });
  }

  //funkcja przenosząca do nowej aktywności z
  //archiwum w której wyświetlane są wszystkie eventy pracodawcy
  void navigateToEmployerArchives(String name) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EmployersArchive(name);
    }));
  }

  //funkcja przenosząca do nowej aktywności ze
  //skrótem w której wyświetlane są wszystkie eventy pracodawcy nie zapłacone tak aby
  //można je było wysłac jako np. screen
  void navigateToEmployerShortcut(
      String name, String sum, List addtions) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EmployersShortcut(name, sum, addtions);
    }));
  }

  //funkcja ustawiająca pole zapłacone we wszystkich wyświetlanych eventach
  void payForAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).selectedRowColor,
        content: Container(
          height: 240,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Na pewno ustawić status zapłacono dla wszystkich wydarzeń? Przeniesie to wszystkie eventy pracodawcy do archiwum oraz usunie wszystkie dodatki!!",
                style: TextStyle(
                    fontSize: 20, color: Theme.of(context).textSelectionColor),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new RaisedButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      //zmiana wszystkich statusow eventow na zaplacone
                      setState(() {
                        this.eventsModelList.forEach((element) {
                          eventHelper.updateEvent(1, element.id);
                        });
                        hoursSum = 0;
                        getHourSum(this.employersModel.name);
                        this.additionsList = [];
                        employersHelper.updateAdditions(
                            "", this.employersModel.name);
                      });
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Theme.of(context).hoverColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  RaisedButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      Navigator.pop(context, true);
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
}
