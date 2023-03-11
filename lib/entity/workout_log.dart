

class WorkoutLog {
  int? _id;
  final int _menuId;
  DateTime? createDate;
  DateTime? updateDate;

  WorkoutLog(this._id, this._menuId, this.createDate, this.updateDate);
  WorkoutLog.empty(this._menuId);

  // Getter&Setter
  int? get id => _id;
  int get menuId => _menuId;
}
