import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:working_time_management/Calendar/calendar.dart';
import 'package:working_time_management/Employers/employers.dart';
import 'package:working_time_management/Workers/workers.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue[900],
        accentColor: Colors.blue,
        cardColor: Colors.orange,
        selectedRowColor: Colors.blue[200],
      ),
      home: MyHomePage(title: 'Menadżer czasu pracy'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _page = 0;
  PageController _controller;
  @override
  void initState() {
    _controller = new PageController(
      initialPage: _page,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(25),
        child: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(widget.title),
        ),
      ),
      bottomNavigationBar: new BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).primaryColor,
        currentIndex: _page,
        onTap: (index) {
          this._controller.animateToPage(index,
              duration: const Duration(milliseconds: 800), curve: Curves.ease);
        },
        items: [
          new BottomNavigationBarItem(
              icon: new Icon(Icons.calendar_today),
              title: new Text("Kalendarz")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.work), title: new Text("Pracodawcy")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.people), title: new Text("Pracownicy")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.search), title: new Text("Wyszukaj")),
        ],
        unselectedItemColor: Theme.of(context).accentColor,
        selectedItemColor: Theme.of(context).cardColor,
      ),
      body: new PageView(
        controller: _controller,
        onPageChanged: (newPage) {
          setState(() {
            this._page = newPage;
          });
        },
        children: <Widget>[
          new Center(
            child: Calendar(),
          ),
          new Center(
            child: Employers(),
          ),
          new Center(
            child: Workers(),
          ),
          new Center(
            child: Text("Wyszukiwarka"),
          ),
        ],
      ),
    );
  }
}
