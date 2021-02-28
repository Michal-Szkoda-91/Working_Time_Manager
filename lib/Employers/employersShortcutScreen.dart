import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:working_time_management/helpers/employersHelper.dart';
import 'package:working_time_management/helpers/eventHelper.dart';
import 'package:working_time_management/models/eventsModel.dart';

class EmployersShortcutScreen extends StatefulWidget {
  final String _name;
  final String _sum;
  final List _additions;

  EmployersShortcutScreen(this._name, this._sum, this._additions);

  @override
  _EmployersShortcutState createState() {
    return _EmployersShortcutState(this._name, this._sum, this._additions);
  }
}

class _EmployersShortcutState extends State<EmployersShortcutScreen> {
  String _name;
  String _sum;
  List _additions;

  EventHelper eventHelper = EventHelper();
  EmployersHelper employersHelper = EmployersHelper();
  List<EventsModel> _eventsModelList = new List();
  int count = 0;
  DateFormat _format = DateFormat("dd-MM-yyyy");

  _EmployersShortcutState(this._name, this._sum, this._additions);

  @override
  void initState() {
    super.initState();
    eventHelper.getHourEmployerSum(this._name).then((event) {
      setState(() {
        event.forEach((element) {
          _eventsModelList.add(EventsModel.fromMapObject(element));
        });
        //sortowanie listy wg daty eventu
        _eventsModelList.sort((a, b) {
          var adate = _format.parse(a.date);
          var bdate = _format.parse(b.date);
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
        title: Text(
          "Podsumowanie",
          style: TextStyle(
            color: Theme.of(context).hoverColor,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                          color: Theme.of(context).textSelectionColor,
                          width: 4.0))),
              height: 350,
              child: _listViewEvents(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                          color: Theme.of(context).textSelectionColor,
                          width: 4.0))),
              height: 100,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(21, 10, 0, 0),
                child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: Theme.of(context).textSelectionColor,
                                width: 4.0))),
                    child: SingleChildScrollView(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                      child: Text(
                        _additions.join("\n"),
                        style: TextStyle(
                          color: Theme.of(context).textSelectionColor,
                        ),
                      ),
                    ))),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: Text(
                  "Suma: " + _sum.toString(),
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).textSelectionColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

//metoda budująca liste eventow
  ListView _listViewEvents() {
    return ListView.builder(
        itemCount: _eventsModelList.length,
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
                          left: BorderSide(
                              color: Theme.of(context).textSelectionColor,
                              width: 4.0))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                    child: Text(
                      _getDayFromNumber(_eventsModelList[position].dayNumber) +
                          " - " +
                          _eventsModelList[position].date +
                          ", " +
                          _eventsModelList[position].workTime +
                          ". (-" +
                          _eventsModelList[position].breakTime.toString() +
                          " min)" +
                          "\nPrzepracowano: " +
                          _eventsModelList[position].workersNumber.toString() +
                          " * " +
                          _eventsModelList[position].hourSum.toString() +
                          " = " +
                          //wyswitlenie sumy godzin
                          (_eventsModelList[position].workersNumber *
                                  _eventsModelList[position].hourSum)
                              .toString() +
                          " godz.",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).textSelectionColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  //funkcja zwracająca dzień tygodnia
  String _getDayFromNumber(int i) {
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
