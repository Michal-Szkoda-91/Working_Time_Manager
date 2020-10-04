import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:working_time_management/helpers/employersHelper.dart';
import 'package:working_time_management/helpers/eventHelper.dart';
import 'package:working_time_management/models/eventsModel.dart';

class EmployersShortcut extends StatefulWidget {
  final String name;
  final String sum;
  final List addtions;

  EmployersShortcut(this.name, this.sum, this.addtions);

  @override
  _EmployersShortcutState createState() {
    return _EmployersShortcutState(this.name, this.sum, this.addtions);
  }
}

class _EmployersShortcutState extends State<EmployersShortcut> {
  String name;
  String sum;
  List addtions;

  EventHelper eventHelper = EventHelper();
  EmployersHelper employersHelper = EmployersHelper();
  List<EventsModel> eventsModelList = new List();
  int count = 0;
  DateFormat format = DateFormat("dd-MM-yyyy");

  _EmployersShortcutState(this.name, this.sum, this.addtions);

  @override
  void initState() {
    super.initState();
    eventHelper.getHourEmployerSum(this.name).then((event) {
      setState(() {
        event.forEach((element) {
          eventsModelList.add(EventsModel.fromMapObject(element));
        });
        //sortowanie listy wg daty eventu
        eventsModelList.sort((a, b) {
          var adate = format.parse(a.date);
          var bdate = format.parse(b.date);
          return adate.compareTo(bdate);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back,
                color: Theme.of(context).selectedRowColor),
            onPressed: () {
              Navigator.pop(context, true);
            }),
        title: Text("Podsumowanie"),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                border:
                    Border(left: BorderSide(color: Colors.blue, width: 3.0))),
            height: 350,
            child: listViewEvents(),
          ),
          Container(
            decoration: BoxDecoration(
                border:
                    Border(left: BorderSide(color: Colors.blue, width: 3.0))),
            height: 100,
            child: listViewAdditions(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: Text(
                  "Suma: " + sum.toString(),
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }

//metoda budująca liste eventow
  ListView listViewEvents() {
    return ListView.builder(
        itemCount: eventsModelList.length,
        itemBuilder: (context, position) {
          return Container(
            height: 40,
            child: ListTile(
              //tytul wyswietlany jak dzien i data
              title: Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 0, 6),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(color: Colors.blue, width: 4.0))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      getDayFromNumber(eventsModelList[position].dayNumber) +
                          " - " +
                          eventsModelList[position].date +
                          ", " +
                          eventsModelList[position].workTime +
                          ". (-" +
                          eventsModelList[position].breakTime.toString() +
                          " min)" +
                          "\nPrzepracowano: " +
                          eventsModelList[position].workersNumber.toString() +
                          " * " +
                          eventsModelList[position].hourSum.toString() +
                          " = " +
                          (eventsModelList[position].workersNumber *
                                  eventsModelList[position].hourSum)
                              .toString() +
                          " godz.",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              onTap: () {},
            ),
          );
        });
  }

  //metoda budująca liste dodatków
  ListView listViewAdditions() {
    return ListView.builder(
        itemCount: addtions.length,
        itemBuilder: (context, position) {
          return Container(
            height: 20,
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 0, 6),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(color: Colors.blue, width: 4.0))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      addtions[position],
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              onTap: () {},
            ),
          );
        });
  }

  //funkcja zwracająca dzień tygodnia
  String getDayFromNumber(int i) {
    switch (i) {
      case 1:
        return "Pon";
        break;
      case 2:
        return "Wt";
        break;
      case 3:
        return "Śr";
        break;
      case 4:
        return "Czw";
        break;
      case 5:
        return "Pią";
        break;
      case 6:
        return "Sob";
        break;
      case 7:
        return "Nie";
        break;
    }
    return null;
  }
}
