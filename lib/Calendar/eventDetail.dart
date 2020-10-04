import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:working_time_management/helpers/eventHelper.dart';
import 'package:working_time_management/models/eventsModel.dart';

class EventDetail extends StatefulWidget {
  final EventsModel eventsModel;

  EventDetail(this.eventsModel);
  @override
  _EventDetailState createState() {
    return _EventDetailState(this.eventsModel);
  }
}

class _EventDetailState extends State<EventDetail> {
  EventsModel eventsModel;
  EventHelper eventHelper = EventHelper();

  List workersList = [];

  _EventDetailState(this.eventsModel);

  @override
  Widget build(BuildContext context) {
    //utworzenie listy pracownikow, sprawdzenie czy sa puste
    if (this.eventsModel.workersPaid != "" &&
        this.eventsModel.workersNotPaid != "") {
      workersList = this.eventsModel.workersNotPaid.split("; ") +
          this.eventsModel.workersPaid.split("; ");
    } else if (this.eventsModel.workersPaid == "") {
      workersList = this.eventsModel.workersNotPaid.split("; ");
    } else if (this.eventsModel.workersNotPaid == "") {
      workersList = this.eventsModel.workersPaid.split("; ");
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Szczegóły Dnia Pracy"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "Data:                 " +
                    getDayFromNumber(this.eventsModel.dayNumber) +
                    ", " +
                    this.eventsModel.date,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "Praca u:           " + this.eventsModel.employer,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "Pracownicy \nnie opłaceni:   " +
                    this.eventsModel.workersNotPaid,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "Pracownicy \nopłaceni:        " + this.eventsModel.workersPaid,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "Czas:               " + this.eventsModel.workTime,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "Przerwa:         " +
                    this.eventsModel.breakTime.toString() +
                    " min",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "Łącny czas:    " +
                    this.eventsModel.hourSum.toString() +
                    " godz.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            //przycisk do ustawiania czy dany event jest juz oplacony
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: Text("Rozliczenie z inwestorem",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LiteRollingSwitch(
                      value: true
                          ? this.eventsModel.isPaid == 1
                          // ignore: dead_code
                          : this.eventsModel.isPaid == 0,
                      textOn: 'Zapłacono',
                      textOff: 'Nie Zap.',
                      colorOn: Theme.of(context).accentColor,
                      colorOff: Colors.red,
                      iconOn: Icons.attach_money,
                      iconOff: Icons.money_off,
                      onChanged: (bool state) {
                        //zapisanie do bazy informacji o zapłaceniu eventu
                        state
                            ? eventsModel.isPaid = 1
                            : this.eventsModel.isPaid = 0;
                        eventHelper.updateEvent(
                            this.eventsModel.isPaid, this.eventsModel.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            //lista pracowników
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Text("Rozliczenie z pracownikami",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Container(
                height: 500,
                child: getList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //budowanie listy pracownikow
  ListView getList() {
    List workersNotPaidList = [];
    List workersPaidList = [];
    workersNotPaidList = this.eventsModel.workersNotPaid.split("; ");
    workersPaidList = this.eventsModel.workersPaid.split("; ");
    return ListView.builder(
        itemCount: workersList.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(50, 3, 50, 3),
            child: Container(
              height: 40,
              child: ListTile(
                  title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    workersList[index],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  LiteRollingSwitch(
                      value: true
                          ? this
                              .eventsModel
                              .workersPaid
                              .contains(workersList[index])
                          // ignore: dead_code
                          : this
                              .eventsModel
                              .workersNotPaid
                              .contains(workersList[index]),
                      textOn: 'Zapłacono',
                      textOff: 'Nie Zap.',
                      colorOn: Theme.of(context).accentColor,
                      colorOff: Colors.red,
                      iconOn: Icons.attach_money,
                      iconOff: Icons.money_off,
                      onChanged: (bool state) {
                        //zapisanie do bazy informacji o zapłaceniu pracownikowi za event
                        if (state) {
                          workersNotPaidList.remove(workersList[index]);
                          workersPaidList.add(workersList[index]);
                          print("nie" + workersNotPaidList.toString());
                          print("tak" + workersPaidList.toString());
                        } else {
                          workersNotPaidList.add(workersList[index]);
                          workersPaidList.remove(workersList[index]);
                          print("nie" + workersNotPaidList.toString());
                          print("tak" + workersPaidList.toString());
                        }
                      })
                ],
              )),
            ),
          );
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
