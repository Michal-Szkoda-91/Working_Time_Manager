import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:working_time_management/helpers/eventHelper.dart';
import 'package:working_time_management/models/eventsModel.dart';

class EmployersArchive extends StatefulWidget {
  final String name;

  EmployersArchive(this.name);

  @override
  _EmployersArchiveState createState() {
    return _EmployersArchiveState(this.name);
  }
}

class _EmployersArchiveState extends State<EmployersArchive> {
  String name;
  EventHelper eventHelper = EventHelper();
  List<EventsModel> eventsModelList = new List();
  int count = 0;
  DateFormat format = DateFormat("dd-MM-yyyy");

  _EmployersArchiveState(this.name);

  @override
  void initState() {
    super.initState();
    eventHelper.getEmployersEventsList(this.name).then((event) {
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
        title: Text("Archiwum" + " - " + name),
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
                        color: Colors.black,
                      ),
                    ),
                    //podtytul wyswietlany z informacjami o pracy
                    subtitle: Text(
                      "Pracowali: " +
                          eventsModelList[position].workersNotPaid +
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
                      ),
                    ),
                    leading: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: CircleAvatar(
                              backgroundColor:
                                  eventsModelList[position].isPaid == 1
                                      ? Theme.of(context).accentColor
                                      : Colors.red,
                              radius: 14.0,
                              child: Icon(
                                eventsModelList[position].isPaid == 1
                                    ? Icons.attach_money
                                    : Icons.money_off,
                                color: Colors.black,
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
