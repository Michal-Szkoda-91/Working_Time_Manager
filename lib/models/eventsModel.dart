//Klasa z modelem Eventu

class EventsModel {
  int _id;
  String _title;
  String _date;
  String _workTime;
  String _employer;
  String _workers;
  int _dayNumber;
  int _breakTime;
  double _hourSum;
  bool _isPayed;

  EventsModel(
      this._title,
      this._date,
      this._workTime,
      this._employer,
      this._workers,
      this._dayNumber,
      this._breakTime,
      this._hourSum,
      this._isPayed);

  int get id => _id;
  String get title => _title;
  String get date => _date;
  String get workTime => _workTime;
  String get employer => _employer;
  String get workers => _workers;
  int get dayNumber => _dayNumber;
  int get breaktTime => _breakTime;
  double get hourSum => _hourSum;
  bool get isPayed => _isPayed;

  //tutaj mozesz ustawiac warunki wpisywania
  set title(String newtitle) {
    this._title = newtitle;
  }

  set date(String newdate) {
    this._date = newdate;
  }

  set workTime(String newWorkTime) {
    this._workTime = newWorkTime;
  }

  set employer(String newemployer) {
    this._employer = newemployer;
  }

  set workers(String newworkers) {
    this._workers = newworkers;
  }

  set dayNumber(int newdayNumber) {
    this._dayNumber = newdayNumber;
  }

  set breakTime(int newbreakTime) {
    this._breakTime = newbreakTime;
  }

  set hourSum(double newhourSum) {
    this._hourSum = newhourSum;
  }

  set isPayed(bool newisPayed) {
    this._isPayed = newisPayed;
  }

  //konwertowanie objektu w mape
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['date'] = _date;
    map['workTime'] = _workTime;
    map['employer'] = _employer;
    map['workers'] = _workers;
    map['dayNumber'] = _dayNumber;
    map['breakTime'] = _breakTime;
    map['hourSum'] = _hourSum;
    map['isPayed'] = _isPayed;
    return map;
  }

  //pobieranie objektu z mapy
  EventsModel.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._date = map['date'];
    this._workTime = map['workTime'];
    this._employer = map['employer'];
    this._workers = map['workers'];
    this._dayNumber = map['dayNumber'];
    this._breakTime = map['breakTime'];
    this._hourSum = map['hourSum'];
    this._isPayed = map['isPayed'];
  }
}
