import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:working_time_management/Employers/addEmployers.dart';
import 'package:working_time_management/Employers/emplyersDetail.dart';
import 'package:working_time_management/helpers/employersHelper.dart';
import 'package:working_time_management/models/employersModel.dart';

class Employers extends StatefulWidget {
  @override
  _EmployersState createState() => _EmployersState();
}

class _EmployersState extends State<Employers> {
  EmployersHelper databasehelper = EmployersHelper();
  List<EmployersModel> employersModelList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    //sprawdzanie czy lista nie jest pusta
    if (employersModelList == null) {
      employersModelList = List<EmployersModel>();
    }
    updateListView();

    return Scaffold(
      body: getlist(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(
              EmployersModel('', '', '', ''), "Dodaj Pracodawcę", 0);
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).accentColor,
      ),
    );
  }

  ListView getlist() {
    return ListView.builder(
        itemCount: count,
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
                this.employersModelList[position].name,
                style: new TextStyle(
                    fontSize: 22, color: Theme.of(context).textSelectionColor),
              ),
              subtitle: Text(
                this.employersModelList[position].shortName,
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
                    deleteEmployers(position);
                  }),
              //po nacisnieciu elementu w liscie
              onTap: () {
                navigateToEmployerDetail(this.employersModelList[position],
                    'Dane Pracodawcy', position);
              },
            ),
          );
        });
  }

  //pobieranie listy modeli
  void updateListView() {
    final Future<Database> dbFuture = databasehelper.initialDatabase();
    dbFuture.then((databse) {
      Future<List<EmployersModel>> employersModelListFuture =
          databasehelper.getEmployersList();
      employersModelListFuture.then((employersModelList) {
        if (this.mounted) {
          setState(() {
            this.employersModelList = employersModelList;
            this.count = employersModelList.length;
          });
        }
      });
    });
  }

  //nawigowanie do strony
  void navigateToDetail(
      EmployersModel employersObject, String title, int position) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddEmployers(employersObject, title, position);
    }));
    if (result == true) {
      updateListView();
    }
  }

  //usuwanie Pracownicy
  deleteEmployers(int position) {
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
                      _delete(context, employersModelList[position]);
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
  void navigateToEmployerDetail(
      EmployersModel employersModel, String title, int position) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EmployersDetail(employersModel, title, position);
    }));
    if (result == true) {
      updateListView();
    }
  }

  //usuwanie pracownika
  void _delete(BuildContext context, EmployersModel employersModel) async {
    int result = await databasehelper.deleteEmployer(employersModel.id);
    if (result != 0) {
      updateListView();
    }
  }
}
