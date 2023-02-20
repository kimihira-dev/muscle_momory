
/// ワークアウトの種類
enum MenuType {
  free(1, 'フリー・ウェイト'),
  body(2, '自重'),
  ;
  const MenuType(this.id, this.name);
  final int id;
  final String name;

  factory MenuType.fromId(id) {
    var result = MenuType.free;
    for (var element in MenuType.values) {
      if (element.id == id) {
        result = element;
        break;
      }
    };
    return result;
  }
}