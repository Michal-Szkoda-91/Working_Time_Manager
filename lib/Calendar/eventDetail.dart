import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:working_time_management/helpers/eventHelper.dart';
import 'package:working_time_management/models/eventsModel.dart';

class EventDetail extends StatefulWidget {
  final String eventTitle;

  EventDetail(this.eventTitle);
  @override
  _EventDetailState createState() {
    return _EventDetailState(this.eventTitle);
  }
}

class _EventDetailState extends State<EventDetail> {
  String eventTitle;
  EventHelper eventHelper = EventHelper();
  EventsModel eventsModel = EventsModel("", "", "", "", "", 0, 0, 0, 0.0, 0);

  _EventDetailState(this.eventTitle);
  @override
  void initState() {
    super.initState();
    getEvent(eventTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Szczegóły Dnia Pracy"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            child: Text(
              "Data:              " +
                  getDayFromNumber(eventsModel.dayNumber) +
                  ", " +
                  eventsModel.date,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            child: Text(
              "Praca u:         " + eventsModel.employer,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            child: Text(
              "Pracowali:     " + eventsModel.workers,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            child: Text(
              "Czas:             " + eventsModel.workTime,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            child: Text(
              "Przerwa:       " + eventsModel.breakTime.toString() + " min",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            child: Text(
              "Łącny czas:  " + eventsModel.hourSum.toString() + " godz.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          //przycisk do ustawiania czy dany event jest juz oplacony
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LiteRollingSwitch(
                  value: true
                      ? eventsModel.isPayed == 1
                      // ignore: dead_code
                      : eventsModel.isPayed == 0,
                  textOn: 'Zapłacono',
                  textOff: 'Nie Zap.',
                  colorOn: Theme.of(context).accentColor,
                  colorOff: Colors.red,
                  iconOn: Icons.attach_money,
                  iconOff: Icons.money_off,
                  onChanged: (bool state) {
                    //zapisanie do bazy informacji o zapłaceniu eventu
                    state ? eventsModel.isPayed = 1 : eventsModel.isPayed = 0;
                    eventHelper.updateEvent(
                        eventsModel.isPayed, eventsModel.id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

//pobieranie eventu po tytule z bazy danych
  void getEvent(String title) async {
    final EventsModel event = await eventHelper.getEventFromDB(title);
    setState(() {
      eventsModel = event;
    });
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