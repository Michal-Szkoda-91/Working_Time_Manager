import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:working_time_management/helpers/eventHelper.dart';
import 'package:working_time_management/models/eventsModel.dart';

class WorkersArchive extends StatefulWidget {
  final String name;
  final String shortname;

  WorkersArchive(this.name, this.shortname);

  @override
  _WorkersArchiveState createState() {
    return _WorkersArchiveState(this.name, this.shortname);
  }
}

class _WorkersArchiveState extends State<WorkersArchive> {
  String name;
  String shortname;
  EventHelper eventHelper = EventHelper();
  List<EventsModel> eventsModelList = new List();
  int count = 0;
  DateFormat format = DateFormat("dd-MM-yyyy");

  _WorkersArchiveState(this.name, this.shortname);

  @override
  void initState() {
    super.initState();
    eventHelper.getWorkersEventsList(this.shortname).then((event) {
      setState(() {
        event.forEach((element) {
          eventsModelList.add(EventsModel.fromMapObject(element));
        });
        //sortowanie listy wg daty eventu
        eventsModelList.sort((a, b) {
          var adate = format.parse(a.date);
          var bdate = format.parse(b.date);
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
          "Archiwum" + " - " + name,
          style: TextStyle(
            color: Theme.of(context).hoverColor,
          ),
        ),
      ),
      body: Center(
        child: ListView.builder(
            itemCount: eventsModelList.length,
            padding: const EdgeInsets.all(3.0),
            itemBuilder: (context, position) {
              return Column(
                children: <Widget>[
                  Divider(height: 1.0),
                  ListTile(
                    //tytul wyswietlany jak dzien i data
                    title: Text(
                      getDayFromNumber(eventsModelList[position].dayNumber) +
                          " - " +
                          eventsModelList[position].date,
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Theme.of(context).textSelectionColor,
                          fontWeight: FontWeight.bold),
                    ),
                    //podtytul wyswietlany z informacjami o pracy
                    subtitle: Text(
                      "Pracował u: " +
                          eventsModelList[position].employer +
                          "\n" +
                          "Czas : " +
                          eventsModelList[position].workTime +
                          ", Przerwa: " +
                          eventsModelList[position].breakTime.toString() +
                          " min" +
                          "\nPrzepracowano: " +
                          eventsModelList[position].hourSum.toString() +
                          " godz.",
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).textSelectionColor),
                    ),
                    leading: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: CircleAvatar(
                              //sprawdanie czy pracownik jest na liscie oplaconych
                              backgroundColor: eventsModelList[position]
                                      .workersPaid
                                      .contains(this.shortname)
                                  ? Theme.of(context).indicatorColor
                                  : Theme.of(context).errorColor,
                              radius: 14.0,
                              child: Icon(
                                eventsModelList[position]
                                        .workersPaid
                                        .contains(this.shortname)
                                    ? Icons.attach_money
                                    : Icons.money_off,
                                color: Theme.of(context).hoverColor,
                              )),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                ],
              );
            }),
      ),
    );
  }

  //funkcja zwracająca dzień tygodnia
  String getDayFromNumber(int i) {
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
