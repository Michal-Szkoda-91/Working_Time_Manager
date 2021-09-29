import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:working_time_management/helpers/eventHelper.dart';
import 'package:working_time_management/models/eventsModel.dart';

class EmployersArchiveScreen extends StatefulWidget {
  final String _name;

  EmployersArchiveScreen(this._name);

  @override
  _EmployersArchiveState createState() {
    return _EmployersArchiveState(this._name);
  }
}

class _EmployersArchiveState extends State<EmployersArchiveScreen> {
  String _name;
  EventHelper eventHelper = EventHelper();
  List<EventsModel> _eventsModelList = [];
  int count = 0;
  DateFormat _format = DateFormat("dd-MM-yyyy");

  _EmployersArchiveState(this._name);

  @override
  void initState() {
    super.initState();
    eventHelper.getEmployersEventsList(this._name).then((event) {
      setState(() {
        event.forEach((element) {
          _eventsModelList.add(EventsModel.fromMapObject(element));
        });
        //sortowanie listy wg daty eventu
        _eventsModelList.sort((a, b) {
          var adate = _format.parse(a.date);
          var bdate = _format.parse(b.date);
          return bdate.compareTo(adate);
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
          "Archiwum" + " - " + _name,
          style: TextStyle(
            color: Theme.of(context).hoverColor,
          ),
        ),
      ),
      body: Center(
        child: ListView.builder(
            itemCount: _eventsModelList.length,
            padding: const EdgeInsets.all(3.0),
            itemBuilder: (context, position) {
              return Column(
                children: <Widget>[
                  Divider(height: 1.0),
                  ListTile(
                    //tytul wyswietlany jak dzien i data
                    title: Text(
                      _getDayFromNumber(_eventsModelList[position].dayNumber) +
                          " - " +
                          _eventsModelList[position].date,
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Theme.of(context).hintColor,
                          fontWeight: FontWeight.bold),
                    ),
                    //podtytul wyswietlany z informacjami o pracy
                    subtitle: Text(
                      "Pracowali: " +
                          _eventsModelList[position].workersNotPaid +
                          " ;" +
                          _eventsModelList[position].workersPaid +
                          "\n" +
                          "Czas : " +
                          _eventsModelList[position].workTime +
                          ", Przerwa: " +
                          _eventsModelList[position].breakTime.toString() +
                          " min" +
                          "\nPrzepracowano: " +
                          _eventsModelList[position].hourSum.toString() +
                          " godz.",
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).hintColor),
                    ),
                    leading: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: CircleAvatar(
                              backgroundColor:
                                  _eventsModelList[position].isPaid == 1
                                      ? Theme.of(context).indicatorColor
                                      : Theme.of(context).errorColor,
                              radius: 14.0,
                              child: Icon(
                                _eventsModelList[position].isPaid == 1
                                    ? Icons.attach_money
                                    : Icons.money_off,
                                color: Theme.of(context).hoverColor,
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  //funkcja zwracająca dzień tygodnia
  String _getDayFromNumber(int i) {
    switch (i) {
      case 1:
        return "Poniedziałek";
        break;
      case 2:
        return "Wtorek";
        break;
      case 3:
        return "Środa";
        break;
      case 4:
        return "Czwartek";
        break;
      case 5:
        return "Piątek";
        break;
      case 6:
        return "Sobota";
        break;
      case 7:
        return "Niedziela";
        break;
    }
    return null;
  }
}
