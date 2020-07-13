import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
          backgroundColor: Colors.blue[900],
          title: Text(widget.title),
        ),
      ),
      bottomNavigationBar: new BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        currentIndex: _page,
        onTap: (index) {
          this._controller.animateToPage(index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut);
        },
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
              icon: new Icon(Icons.calendar_today),
              title: new Text("Kalendarz")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.work), title: new Text("Pracodawcy")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.people), title: new Text("Pracownicy")),
        ],
        unselectedItemColor: Colors.blue,
        selectedItemColor: Colors.orange,
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
            child: Text("Kalendarz"),
          ),
          new Center(
            child: Text("Pracodawcy"),
          ),
          new Center(
            child: Text("Pracownicy"),
          ),
        ],
      ),
    );
  }
}
