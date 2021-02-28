//Klasa z modelem Eventu

class EventsModel {
  int _id;
  String _title;
  String _date;
  String _workTime;
  String _employer;
  String _workersNotPaid;
  String _workersPaid;
  int _workersNumber;
  int _dayNumber;
  int _breakTime;
  double _hourSum;
  int _isPaid;

  EventsModel(
      this._title,
      this._date,
      this._workTime,
      this._employer,
      this._workersNotPaid,
      this._workersPaid,
      this._workersNumber,
      this._dayNumber,
      this._breakTime,
      this._hourSum,
      this._isPaid);

  int get id => _id;
  String get title => _title;
  String get date => _date;
  String get workTime => _workTime;
  String get employer => _employer;
  String get workersNotPaid => _workersNotPaid;
  String get workersPaid => _workersPaid;
  int get workersNumber => _workersNumber;
  int get dayNumber => _dayNumber;
  int get breakTime => _breakTime;
  double get hourSum => _hourSum;
  int get isPaid => _isPaid;

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

  set workersNotPaid(String newworkersNotPaid) {
    this._workersNotPaid = newworkersNotPaid;
  }

  set workersPaid(String newworkersPaid) {
    this._workersPaid = newworkersPaid;
  }

  set workersNumber(int newworkersNumber) {
    this._workersNumber = newworkersNumber;
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

  set isPaid(int newisPaid) {
    this._isPaid = newisPaid;
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
    map['workersNotPaid'] = _workersNotPaid;
    map['workersPaid'] = _workersPaid;
    map['workersNumber'] = _workersNumber;
    map['dayNumber'] = _dayNumber;
    map['breakTime'] = _breakTime;
    map['hourSum'] = _hourSum;
    map['isPaid'] = _isPaid;
    return map;
  }

  //pobieranie objektu z mapy
  EventsModel.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._date = map['date'];
    this._workTime = map['workTime'];
    this._employer = map['employer'];
    this._workersNotPaid = map['workersNotPaid'];
    this._workersPaid = map['workersPaid'];
    this._workersNumber = map['workersNumber'];
    this._dayNumber = map['dayNumber'];
    this._breakTime = map['breakTime'];
    this._hourSum = map['hourSum'];
    this._isPaid = map['isPaid'];
  }
}
