
/// ワークアウトの単位
enum WorkoutUnit {
  kg(1, 'kb'),
  second(11, '秒'),
  ;
  const WorkoutUnit(this.id, this.name);
  final int id;
  final String name;

  factory WorkoutUnit.fromId(id) {
    var result = WorkoutUnit.kg;
    for (var element in WorkoutUnit.values) {
      if (element.id == id) {
        result = element;
        break;
      }
    };
    return result;
  }
}