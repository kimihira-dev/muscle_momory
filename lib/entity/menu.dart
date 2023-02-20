import 'package:muscle_memory/entity/part.dart';

import '../const.dart';

class Menu {
  int? _id;
  String name = '';
  MenuType type = MenuType.free;
  List<Part> parts = [];

  /// コンストラクタ
  Menu(this._id, this.name, this.type, this.parts);
  /// 空データ用コンストラクタ
  Menu.empty();

  // Getter&Setter
  int? get id => _id;
}