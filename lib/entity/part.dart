class Part {
  int? id;
  String name = '';
  int recoveryTime = 0;
  DateTime? createDate;
  DateTime? updateDate;

  Part(this.id, this.name, this.recoveryTime, this.createDate, this.updateDate);
  /// 空データ用コンストラクタ
  Part.empty();
}