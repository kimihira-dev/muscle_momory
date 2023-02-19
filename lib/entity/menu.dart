import 'package:muscle_memory/entity/part.dart';

import '../const.dart';

class Menu {
  int? _id;
  String name = '';
  WorkoutUnit workOutUnit = WorkoutUnit.kg;
  List<Part> parts = [];

  /// コンストラクタ
  Menu(this._id, this.name, this.workOutUnit, this.parts);
  /// 空データ用コンストラクタ
  Menu.empty();

  // Getter&Setter
  int? get id => _id;
}