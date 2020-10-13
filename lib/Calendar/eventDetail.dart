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
  List workersNotPaidList = [];
  List workersPaidList = [];

  _EventDetailState(this.eventsModel);

  @override
  Widget build(BuildContext context) {
    if (this.eventsModel.workersPaid != "" &&
        this.eventsModel.workersNotPaid != "") {
      workersList = this.eventsModel.workersNotPaid.split("; ") +
          this.eventsModel.workersPaid.split("; ");
      workersNotPaidList = this.eventsModel.workersNotPaid.split("; ");
      workersPaidList = this.eventsModel.workersPaid.split("; ");
    } else if (this.eventsModel.workersPaid == "") {
      workersList = this.eventsModel.workersNotPaid.split("; ");
      workersNotPaidList = this.eventsModel.workersNotPaid.split("; ");
    } else if (this.eventsModel.workersNotPaid == "") {
      workersList = this.eventsModel.workersPaid.split("; ");
      workersPaidList = this.eventsModel.workersPaid.split("; ");
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
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textSelectionColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "Praca u:           " + this.eventsModel.employer,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textSelectionColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "Pracownicy :   " + workersList.join("; "),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textSelectionColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "Czas:               " + this.eventsModel.workTime,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textSelectionColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "Przerwa:         " +
                    this.eventsModel.breakTime.toString() +
                    " min",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textSelectionColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "Łączny czas:    " +
                    this.eventsModel.hourSum.toString() +
                    " godz.",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textSelectionColor),
              ),
            ),
            //przycisk do ustawiania czy dany event jest juz oplacony
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: Text("Rozliczenie z inwestorem",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textSelectionColor)),
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
                      colorOn: Theme.of(context).indicatorColor,
                      colorOff: Theme.of(context).errorColor,
                      iconOn: (Icons.attach_money),
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
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textSelectionColor)),
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
    return ListView.builder(
        itemCount: eventsModel.workersNumber,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(50, 3, 50, 3),
            child: Container(
              height: 40,
              child: ListTile(
                  title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(workersList[index],
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textSelectionColor)),
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
                      colorOn: Theme.of(context).indicatorColor,
                      colorOff: Theme.of(context).errorColor,
                      iconOn: Icons.attach_money,
                      iconOff: Icons.money_off,
                      onChanged: (state) {
                        //inicjowanie poprawnych wartosci list
                        if (state) {
                          //utworzenie listy na podstawie statusu przyciskow
                          if (!workersPaidList.contains(workersList[index])) {
                            workersPaidList.add(workersList[index]);
                            workersNotPaidList.remove(workersList[index]);
                          }
                        } else {
                          if (!workersNotPaidList
                              .contains(workersList[index])) {
                            workersPaidList.remove(workersList[index]);
                            workersNotPaidList.add(workersList[index]);
                          }
                        }
                        //zapis danych do bazy
                        if (workersNotPaidList.isNotEmpty) {
                          eventHelper.updateWorkersNotPaid(this.eventsModel.id,
                              workersNotPaidList.join("; "));
                        } else {
                          eventHelper.updateWorkersNotPaid(
                              this.eventsModel.id, "");
                        }
                        if (workersPaidList.isNotEmpty) {
                          eventHelper.updateWorkersPaid(
                              this.eventsModel.id, workersPaidList.join("; "));
                        } else {
                          eventHelper.updateWorkersPaid(
                              this.eventsModel.id, "");
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
