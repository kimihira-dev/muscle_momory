import 'package:muscle_memory/entity/part.dart';

import '../const.dart';

class Menu {
  int? _id;
  String name = '';
  MenuType type = MenuType.free;
  List<Part> parts = [];
  bool weightFlg = false;
  bool countFlg = false;
  bool timeFlg = false;
  DateTime? createAt;
  DateTime? updateAt;

  /// コンストラクタ
  Menu(
    this._id,
    this.name,
    this.type,
    this.weightFlg,
    this.countFlg,
    this.timeFlg,
    this.parts,
  );

  /// 空データ用コンストラクタ
  Menu.empty();

  // Getter&Setter
  int? get id => _id;
}
