//druga strona do dodawania pracownika
import 'package:flutter/material.dart';
import 'package:working_time_management/helpers/employersHelper.dart';
import 'package:working_time_management/models/employersModel.dart';

// ignore: must_be_immutable
class AddEmployers extends StatefulWidget {
  final String title;
  final EmployersModel employersModel;
  int position;

  AddEmployers(this.employersModel, this.title, this.position);

  @override
  _AddEmployersState createState() {
    return _AddEmployersState(this.title, this.employersModel);
  }
}

class _AddEmployersState extends State<AddEmployers> {
  EmployersModel employersModel;
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController shortNameController = new TextEditingController();
  String title;
  EmployersHelper employersHelper = EmployersHelper();
  RegExp re = RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*^%0-9-]');

  _AddEmployersState(this.title, this.employersModel);

  @override
  Widget build(BuildContext context) {
    namecontroller.text = employersModel.name;
    shortNameController.text = employersModel.shortName;
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
                  hintText: 'Imie pracodawcy',
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
                          "wypełnij wszystkie pola! Nie używaj znaków specjalnych!");
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
                        shortNameController.text = "";
                        namecontroller.text = "";
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
    employersModel.name = namecontroller.text;
  }

  void updateShortname() {
    employersModel.shortName = shortNameController.text;
  }

//funkcja zatwierdzajaca dane
  void _saveData(String nameGets, String shortNameGets) async {
    Navigator.pop(context, true);
    int checkResult = await employersHelper.getEmployerName(nameGets);
    int checkResultShortName =
        await employersHelper.getWorkerShortName(shortNameGets);
    if (checkResult == 0 &&
        nameGets.substring(nameGets.length - 1) != " " &&
        checkResultShortName == 0 &&
        shortNameGets.substring(shortNameGets.length - 1) != " ") {
      int result;
      result = await employersHelper.insertEmployer(employersModel);
      if (result != 0) {
        _showDialog('Status', 'Dodano pracodawcę');
      } else {
        _showDialog('Status', 'Nie udało się dodać pracodawcy');
      }
    } else {
      _showDialog('Status', 'Ten pracodawca już istnieje');
    }
  }

  void _showDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      backgroundColor: Theme.of(context).selectedRowColor,
      title: Text(title,
          style: (TextStyle(color: Theme.of(context).textSelectionColor))),
      content: Text(message,
          style: (TextStyle(color: Theme.of(context).textSelectionColor))),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
