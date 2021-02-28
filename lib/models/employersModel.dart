//klasa pracownika
class EmployersModel {
  int _id;
  String _name;
  String _shortName;
  String _additions;
  String _notes;

  EmployersModel(this._name, this._shortName, this._additions, this._notes);

  int get id => _id;
  String get name => _name;
  String get shortName => _shortName;
  String get additions => _additions;
  String get notes => _notes;

  //tutaj mozesz ustawiac warunki wpisywania
  set name(String newname) {
    this._name = newname;
  }

  set shortName(String newShortname) {
    this._shortName = newShortname;
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
    map['additions'] = _additions;
    map['notes'] = _notes;
    return map;
  }

  //pobieranie objektu z mapy
  EmployersModel.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name = map['name'];
    this._shortName = map['shortName'];
    this._additions = map['additions'];
    this._notes = map['notes'];
  }
}
