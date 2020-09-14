//druga strona do dodawania pracownika
import 'package:flutter/material.dart';
import 'package:working_time_management/helpers/workersHelper.dart';
import 'package:working_time_management/models/workersModel.dart';

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
                hintText: 'Imie pracownika',
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
    workersModel.name = namecontroller.text;
  }

  void updateShortname() {
    workersModel.shortName = shortNameController.text;
  }

//funkcja zatwierdzajaca dane
  void _saveData(String nameGets) async {
    Navigator.pop(context, true);
    int checkResult = await workersHelper.getWorkerName(nameGets);
    if (checkResult == 0) {
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
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
