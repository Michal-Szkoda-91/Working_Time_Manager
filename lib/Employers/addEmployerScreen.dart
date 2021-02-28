//druga strona do dodawania pracownika
import 'package:flutter/material.dart';
import 'package:working_time_management/helpers/employersHelper.dart';
import 'package:working_time_management/models/employersModel.dart';

// ignore: must_be_immutable
class AddEmployersScreen extends StatefulWidget {
  final String _title;
  final EmployersModel employersModel;
  int position;

  AddEmployersScreen(this.employersModel, this._title, this.position);

  @override
  _AddEmployersState createState() {
    return _AddEmployersState();
  }
}

class _AddEmployersState extends State<AddEmployersScreen> {
  TextEditingController _namecontroller = new TextEditingController();
  TextEditingController _shortNameController = new TextEditingController();
  EmployersHelper employersHelper = EmployersHelper();
  RegExp _reg = RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*^%0-9-]');

  @override
  Widget build(BuildContext context) {
    _namecontroller.text = widget.employersModel.name;
    _shortNameController.text = widget.employersModel.shortName;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget._title,
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
                _updateName();
              },
              decoration: InputDecoration(
                  hintText: 'Imie pracodawcy',
                  fillColor: Theme.of(context).textSelectionColor),
              controller: _namecontroller,
            ),
            TextField(
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textSelectionColor),
                onChanged: (value) {
                  _updateShortname();
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
                controller: _shortNameController),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new RaisedButton(
                  color: Theme.of(context).accentColor,
                  onPressed: () {
                    if (_shortNameController.text.isEmpty ||
                        _namecontroller.text.isEmpty ||
                        _reg.hasMatch(_shortNameController.text) ||
                        _reg.hasMatch(_namecontroller.text)) {
                      _showDialog("Błąd",
                          "Wypełnij wszystkie pola! Nie używaj znaków specjalnych!");
                    } else {
                      _saveData(
                          _namecontroller.text, _shortNameController.text);
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
                        _shortNameController.text = "";
                        _namecontroller.text = "";
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
  void _updateName() {
    widget.employersModel.name = _namecontroller.text;
  }

  void _updateShortname() {
    widget.employersModel.shortName = _shortNameController.text;
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
      result = await employersHelper.insertEmployer(widget.employersModel);
      if (result != 0) {
        _showDialog('Status', 'Dodano pracodawcę');
      } else {
        _showDialog('Status', 'Nie udało się dodać pracodawcy');
      }
    } else {
      _showDialog('Status', 'Ten pracodawca już istnieje');
    }
  }

  void _showDialog(String _title, String message) {
    AlertDialog alertDialog = AlertDialog(
      backgroundColor: Theme.of(context).selectedRowColor,
      title: Text(_title,
          textAlign: TextAlign.center,
          style: (TextStyle(color: Theme.of(context).textSelectionColor))),
      content: Text(message,
          textAlign: TextAlign.center,
          style: (TextStyle(color: Theme.of(context).textSelectionColor))),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
