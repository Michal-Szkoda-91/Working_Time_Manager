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
      updateListView();
    }
    updateListView();

    return Scaffold(
      body: getlist(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(
              EmployersModel('', '', 0.0, '', ''), "Dodaj Pracodawce", 0);
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: "Dodaj uzytkownika",
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
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Icons.arrow_forward_ios),
              ),
              //wyswietlenie imienia i tytulu
              title: Text(
                this.employersModelList[position].name,
                style: new TextStyle(fontSize: 22),
              ),
              subtitle: Text(
                this.employersModelList[position].shortName,
                style: new TextStyle(fontSize: 14),
              ),
              //ikona usowania oraz dodana do niej metoda
              trailing: GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () {
                    deleteEmployers(position);
                  }),
              //po nacisnieciu elementu w liscie
              onTap: () {
                navigateToWorkerDetail(this.employersModelList[position],
                    'Dane Pracodawcy', position);
              },
            ),
          );
        });
  }

  //dodawanie rekordow do bazy
  void updateListView() {
    final Future<Database> dbFuture = databasehelper.initialDatabase();
    dbFuture.then((databse) {
      Future<List<EmployersModel>> employersModelListFuture =
          databasehelper.getEmployersList();
      employersModelListFuture.then((employersModelList) {
        setState(() {
          this.employersModelList = employersModelList;
          this.count = employersModelList.length;
        });
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
        content: Container(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Napewno usunąć pracodawcę?",
                style: TextStyle(fontSize: 20),
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

  //nawigowanie do strony z wyswietleniem informacji o pracodawcy
  void navigateToWorkerDetail(
      EmployersModel employersModel, String title, int position) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EmployersDetail(employersModel, title, position);
    }));
  }

  //usuwanie pracownika
  void _delete(BuildContext context, EmployersModel employersModel) async {
    int result = await databasehelper.deleteEmployer(employersModel.id);
    if (result != 0) {
      updateListView();
    }
  }
}
