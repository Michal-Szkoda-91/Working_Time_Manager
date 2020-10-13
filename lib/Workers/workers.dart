import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:working_time_management/Workers/workersDetail.dart';
import 'package:working_time_management/helpers/workersHelper.dart';
import 'package:working_time_management/models/workersModel.dart';

import 'addWorkers.dart';

class Workers extends StatefulWidget {
  @override
  _WorkersState createState() => _WorkersState();
}

class _WorkersState extends State<Workers> {
  WorkersHelper databasehelper = WorkersHelper();
  List<WorkersModel> workersModelList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    //sprawdzanie czy lista nie jest pusta
    if (workersModelList == null) {
      workersModelList = List<WorkersModel>();
    }
    updateListView();

    return Scaffold(
      body: getlist(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(
              WorkersModel('', '', 0.0, '', ''), "Dodaj Pracownika", 0);
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).accentColor,
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
                backgroundColor: Theme.of(context).accentColor,
                child: Icon(Icons.arrow_forward_ios),
              ),
              //wyswietlenie imienia i tytulu
              title: Text(
                this.workersModelList[position].name,
                style: new TextStyle(fontSize: 22),
              ),
              subtitle: Text(
                this.workersModelList[position].shortName,
                style: new TextStyle(fontSize: 14),
              ),
              //ikona usowania oraz dodana do niej metoda
              trailing: GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).accentColor,
                  ),
                  onTap: () {
                    deleteWorkers(position);
                  }),
              //po nacisnieciu elementu w liscie
              onTap: () {
                navigateToWorkerDetail(this.workersModelList[position],
                    'Dane Pracownika', position);
              },
            ),
          );
        });
  }

  //pobieranie listy modeli
  void updateListView() {
    final Future<Database> dbFuture = databasehelper.initialDatabase();
    dbFuture.then((databse) {
      Future<List<WorkersModel>> workersModelListFuture =
          databasehelper.getWorkersList();
      workersModelListFuture.then((workersModelList) {
        if (this.mounted) {
          setState(() {
            this.workersModelList = workersModelList;
            this.count = workersModelList.length;
          });
        }
      });
    });
  }

  //nawigowanie do strony
  void navigateToDetail(
      WorkersModel workersObject, String title, int position) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddWorkers(workersObject, title, position);
    }));
    if (result == true) {
      updateListView();
    }
  }

  //usuwanie Pracownicy
  deleteWorkers(int position) {
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
                "Napewno usunąć pracownika?",
                style: TextStyle(
                    fontSize: 20, color: Theme.of(context).textSelectionColor),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new RaisedButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      _delete(context, workersModelList[position]);
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

  //nawigowanie do strony z wyswietleniem informacji o pracowniku
  void navigateToWorkerDetail(
      WorkersModel workersModel, String title, int position) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return WorkersDetail(workersModel, title, position);
    }));
  }

  //usuwanie pracownika
  void _delete(BuildContext context, WorkersModel workersModel) async {
    int result = await databasehelper.deleteWorker(workersModel.id);
    if (result != 0) {
      updateListView();
    }
  }
}
