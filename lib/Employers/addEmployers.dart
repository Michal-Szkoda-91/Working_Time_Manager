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
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            TextField(
              style: new TextStyle(fontWeight: FontWeight.bold),
              onChanged: (value) {
                updateName();
              },
              decoration: InputDecoration(
                hintText: 'Imie pracodawcy',
              ),
              controller: namecontroller,
            ),
            TextField(
                style: new TextStyle(fontWeight: FontWeight.bold),
                onChanged: (value) {
                  updateShortname();
                },
                maxLength: 5,
                decoration: InputDecoration(
                  hintText: 'Skrót imienia (max 5 liter)',
                  counterStyle:
                      new TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
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
                      _saveData(namecontroller.text);
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
                        fontSize: 16,
                      ),
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
  void _saveData(String nameGets) async {
    Navigator.pop(context, true);
    int checkResult = await employersHelper.getEmployerName(nameGets);
    if (checkResult == 0 && nameGets.substring(nameGets.length - 1) != " ") {
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
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
