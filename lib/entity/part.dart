class Part {
  int? id;
  String name = '';
  int recoveryTime = 0;
  DateTime? createAt;
  DateTime? updateAt;

  Part(this.id, this.name, this.recoveryTime, this.createAt, this.updateAt);
  /// 空データ用コンストラクタ
  Part.empty();
}