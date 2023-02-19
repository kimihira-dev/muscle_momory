
/// ワークアウトの単位
enum WorkoutUnit {
  kg(1, 'kb'),
  second(11, '秒'),
  ;
  const WorkoutUnit(this.id, this.name);
  final int id;
  final String name;
}