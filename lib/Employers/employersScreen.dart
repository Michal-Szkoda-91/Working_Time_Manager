import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:working_time_management/Employers/addEmployerScreen.dart';
import 'package:working_time_management/Employers/emplyersDetailScreen.dart';
import 'package:working_time_management/helpers/employersHelper.dart';
import 'package:working_time_management/models/employersModel.dart';

class EmployersScreen extends StatefulWidget {
  @override
  _EmployersState createState() => _EmployersState();
}

class _EmployersState extends State<EmployersScreen> {
  EmployersHelper employershelper = EmployersHelper();
  List<EmployersModel> _employersModelList;
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    //sprawdzanie czy lista nie jest pusta
    if (_employersModelList == null) {
      _employersModelList = List<EmployersModel>();
    }
    _updateListView();

    return Scaffold(
      body: _getlist(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToDetail(
              EmployersModel('', '', '', ''), "Dodaj Pracodawcę", 0);
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).accentColor,
      ),
    );
  }

  ListView _getlist() {
    return ListView.builder(
        itemCount: _count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Theme.of(context).selectedRowColor,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                child: Icon(Icons.arrow_forward_ios),
              ),
              //wyswietlenie imienia i tytulu
              title: Text(
                this._employersModelList[position].name,
                style: new TextStyle(
                    fontSize: 22, color: Theme.of(context).textSelectionColor),
              ),
              subtitle: Text(
                this._employersModelList[position].shortName,
                style: new TextStyle(
                    fontSize: 16, color: Theme.of(context).textSelectionColor),
              ),
              //ikona usowania oraz dodana do niej metoda
              trailing: GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).accentColor,
                  ),
                  onTap: () {
                    _deleteEmployers(position);
                  }),
              //po nacisnieciu elementu w liscie
              onTap: () {
                _navigateToEmployerDetail(this._employersModelList[position],
                    'Dane Pracodawcy', position);
              },
            ),
          );
        });
  }

  //pobieranie listy modeli
  void _updateListView() {
    final Future<Database> dbFuture = employershelper.initialDatabase();
    dbFuture.then((databse) {
      Future<List<EmployersModel>> employersModelListFuture =
          employershelper.getEmployersList();
      employersModelListFuture.then((_employersModelList) {
        if (this.mounted) {
          setState(() {
            this._employersModelList = _employersModelList;
            this._count = _employersModelList.length;
          });
        }
      });
    });
  }

  //nawigowanie do strony
  void _navigateToDetail(
      EmployersModel employersObject, String title, int position) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddEmployersScreen(employersObject, title, position);
    }));
    if (result == true) {
      _updateListView();
    }
  }

  //usuwanie Pracownicy
  _deleteEmployers(int position) {
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
                "Na pewno usunąć pracodawcę?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20, color: Theme.of(context).textSelectionColor),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new RaisedButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      _delete(context, _employersModelList[position]);
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

  //nawigowanie do strony z wyswietleniem informacji o pracodawcy
  void _navigateToEmployerDetail(
      EmployersModel employersModel, String title, int position) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EmployersDetailScreen(employersModel, title, position);
    }));
    if (result == true) {
      _updateListView();
    }
  }

  //usuwanie pracownika
  void _delete(BuildContext context, EmployersModel employersModel) async {
    int result = await employershelper.deleteEmployer(employersModel.id);
    if (result != 0) {
      _updateListView();
    }
  }
}
