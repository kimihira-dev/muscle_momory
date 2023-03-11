

class WorkoutLogSet {
  final int _workoutLogId;
  int? id;
  double? weight;
  int? count;
  int? time;
  double? bodyWight;
  DateTime? createDate;
  DateTime? updateDate;

  WorkoutLogSet.empty(this._workoutLogId);

  WorkoutLogSet(
      this._workoutLogId,
      this.id,
      this.weight,
      this.count,
      this.time,
      this.bodyWight,
      this.createDate,
      this.updateDate);

  // Getter&Setter
  int? get workoutLogId => _workoutLogId;
}
