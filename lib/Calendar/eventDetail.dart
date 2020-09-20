import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  _EventDetailState(this.eventTitle);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detale eventu"),
      ),
      body: Column(
        children: [Text(eventTitle)],
      ),
    );
  }
}
