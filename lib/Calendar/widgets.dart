import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

import '../globals.dart';

//widget dodawania planowanego czasu rozpoczecia pracy
class TimeWorkStart extends StatefulWidget {
  TimeWorkStart({
    Key key,
  }) : super(key: key);

  @override
  _TimeWorkStart createState() => _TimeWorkStart();
}

class _TimeWorkStart extends State<TimeWorkStart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TimePickerSpinner(
        minutesInterval: 5,
        is24HourMode: true,
        normalTextStyle: TextStyle(
          fontSize: 20,
          color: Theme.of(context).backgroundColor,
          fontWeight: FontWeight.w500,
        ),
        highlightedTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).hintColor),
        spacing: 1,
        itemHeight: 25,
        isForce2Digits: true,
        onTimeChange: (time) {
          setState(() {
            timeStart = getHourString(time);
            workStart = time;
          });
        },
      ),
    );
  }
}

//widget dodawania planowanego czasu pracy
class TimeWorkStop extends StatefulWidget {
  TimeWorkStop({
    Key key,
  }) : super(key: key);

  @override
  _TimeWorkStop createState() => _TimeWorkStop();
}

class _TimeWorkStop extends State<TimeWorkStop> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TimePickerSpinner(
        minutesInterval: 5,
        is24HourMode: true,
        normalTextStyle: TextStyle(
          fontSize: 20,
          color: Theme.of(context).backgroundColor,
          fontWeight: FontWeight.w500,
        ),
        highlightedTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).hintColor),
        spacing: 1,
        itemHeight: 25,
        isForce2Digits: true,
        onTimeChange: (time) {
          setState(() {
            timeStop = getHourString(time);
            workStop = time;
          });
        },
      ),
    );
  }
}

//widget dodawania przerwy
class BreakTime extends StatefulWidget {
  BreakTime({
    Key key,
  }) : super(key: key);

  @override
  _BreakTime createState() => _BreakTime();
}

class _BreakTime extends State<BreakTime> {
  @override
  void initState() {
    super.initState();
    _setvalue(0.0);
  }

  double breakValue;
  void _setvalue(double value) {
    setState(() {
      breakValue = value;
      timeBreak = (breakValue * 90).floor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              'Przerwa: ${(breakValue * 90).round()} minut.',
              style:
                  TextStyle(fontSize: 16, color: Theme.of(context).hintColor),
            ),
            ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Slider(
                  value: breakValue,
                  onChanged: _setvalue,
                  activeColor: Theme.of(context).backgroundColor,
                  divisions: 18,
                ))
          ],
        ),
      ),
    );
  }
}

//funkcja zwracajaca napis bedacy czasem pracy, dodaje 0 jesli liczba jest jednocyfrowa
String getHourString(var data) {
  String houors = data.hour.toString();
  if (houors.length < 2) {
    houors = "0" + houors;
  }
  String minutes = data.minute.toString();
  if (minutes.length < 2) {
    minutes = "0" + minutes;
  }
  String napis = houors + ":" + minutes;
  return napis;
}

//widget do wyświetlania wybranych pracowników danego eventu
class MultiSelectChip extends StatefulWidget {
  final List<String> reportList;
  final Function(List<String>) onSelectionChanged;

  MultiSelectChip(this.reportList, {this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChoices = [];

  _buildChoiceList() {
    List<Widget> choices = [];

    widget.reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          backgroundColor: Theme.of(context).backgroundColor,
          label: Text(
            item,
            style: TextStyle(fontSize: 18, color: Theme.of(context).hoverColor),
          ),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
