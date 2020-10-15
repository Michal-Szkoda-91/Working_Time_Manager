//druga strona do dodawania pracownika
import 'package:flutter/material.dart';
import 'package:working_time_management/helpers/workersHelper.dart';
import 'package:working_time_management/models/workersModel.dart';

// ignore: must_be_immutable
class AddWorkers extends StatefulWidget {
  final String title;
  final WorkersModel workersModel;
  int position;

  AddWorkers(this.workersModel, this.title, this.position);

  @override
  _AddWorkersState createState() {
    return _AddWorkersState(this.title, this.workersModel);
  }
}

class _AddWorkersState extends State<AddWorkers> {
  WorkersModel workersModel;
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController shortNameController = new TextEditingController();
  String title;
  WorkersHelper workersHelper = WorkersHelper();
  RegExp re = RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*^%0-9-]');

  _AddWorkersState(this.title, this.workersModel);

  @override
  Widget build(BuildContext context) {
    namecontroller.text = workersModel.name;
    shortNameController.text = workersModel.shortName;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).hoverColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            TextField(
              cursorColor: Theme.of(context).textSelectionColor,
              style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textSelectionColor),
              onChanged: (value) {
                updateName();
              },
              decoration: InputDecoration(
                  hintText: 'Imię pracownika',
                  fillColor: Theme.of(context).textSelectionColor),
              controller: namecontroller,
            ),
            TextField(
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textSelectionColor),
                onChanged: (value) {
                  updateShortname();
                },
                maxLength: 5,
                cursorColor: Theme.of(context).textSelectionColor,
                decoration: InputDecoration(
                  hintText: 'Skrót imienia (max 5 liter)',
                  fillColor: Theme.of(context).textSelectionColor,
                  counterStyle: new TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Theme.of(context).textSelectionColor),
                ),
                controller: shortNameController),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new RaisedButton(
                  color: Theme.of(context).accentColor,
                  onPressed: () {
                    if (shortNameController.text.isEmpty ||
                        namecontroller.text.isEmpty ||
                        re.hasMatch(shortNameController.text) ||
                        re.hasMatch(namecontroller.text)) {
                      _showDialog("Błąd",
                          "Wypełnij wszystkie pola! Nie używaj znaków specjalnych!");
                    } else {
                      _saveData(namecontroller.text, shortNameController.text);
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      //anulowanie wpisywanego tekstu
                      Navigator.pop(context);
                      setState(() {
                        shortNameController.text = " ";
                        namecontroller.text = " ";
                      });
                    },
                    child: Text(
                      "Anuluj",
                      style: TextStyle(
                          fontSize: 16, color: Theme.of(context).hoverColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //funkcje pomocnicze do ustawienia imienia i ksywy
  void updateName() {
    workersModel.name = namecontroller.text;
  }

  void updateShortname() {
    workersModel.shortName = shortNameController.text;
  }

//funkcja zatwierdzajaca dane
  void _saveData(String nameGets, String shortNameGets) async {
    Navigator.pop(context, true);
    int checkResultName = await workersHelper.getWorkerName(nameGets);
    int checkResultShortName =
        await workersHelper.getWorkerShortName(shortNameGets);
    if (checkResultName == 0 &&
        nameGets.substring(nameGets.length - 1) != " " &&
        checkResultShortName == 0 &&
        shortNameGets.substring(shortNameGets.length - 1) != " ") {
      int result;
      result = await workersHelper.insertWorker(workersModel);
      if (result != 0) {
        _showDialog('Status', 'Dodano pracownika');
      } else {
        _showDialog('Status', 'Nie udało się dodać pracownikia');
      }
    } else {
      _showDialog('Status', 'Ten pracownik już istnieje');
    }
  }

  void _showDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      backgroundColor: Theme.of(context).selectedRowColor,
      title: Text(title,
          textAlign: TextAlign.center,
          style: (TextStyle(color: Theme.of(context).textSelectionColor))),
      content: Text(message,
          textAlign: TextAlign.center,
          style: (TextStyle(color: Theme.of(context).textSelectionColor))),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
