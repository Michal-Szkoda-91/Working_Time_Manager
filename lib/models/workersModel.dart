//klasa pracownika
class WorkersModel {
  int _id;
  String _name;
  String _shortName;
  double _hoursSum;
  String _additions;
  String _notes;

  WorkersModel(this._name, this._shortName, this._hoursSum, this._additions,
      this._notes);

  int get id => _id;
  String get name => _name;
  String get shortName => _shortName;
  double get hoursSum => _hoursSum;
  String get additions => _additions;
  String get notes => _notes;

  //tutaj mozesz ustawiac warunki wpisywania
  set name(String newname) {
    this._name = newname;
  }

  set shortName(String newShortname) {
    this._shortName = newShortname;
  }

  set hoursSum(double newsum) {
    this._hoursSum = newsum;
  }

  set additions(String list) {
    this._additions = list;
  }

  set notes(String notes) {
    this._notes = notes;
  }

  //konwertowanie objektu w mape
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['name'] = _name;
    map['shortName'] = _shortName;
    map['hoursSum'] = _hoursSum;
    map['additions'] = _additions;
    map['notes'] = _notes;
    return map;
  }

  //pobieranie objektu z mapy
  WorkersModel.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name = map['name'];
    this._shortName = map['shortName'];
    this._hoursSum = map['hoursSum'];
    this._additions = map['additions'];
    this._notes = map['notes'];
  }
}
