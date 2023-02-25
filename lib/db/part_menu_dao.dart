import 'package:muscle_memory/db/db_factory.dart';
import 'package:sqflite/sqflite.dart';

class PartMenuDao {
  final DbFactory factory;

  const PartMenuDao(this.factory);

  Future<void> save(part_id, menu_id) async {
    var helper = PartMenuDaoHelper(factory);
    try {
      await helper.open();

      var result;
      if (part_id != null && menu_id != null) {
        result = await helper.fetch(part_id, menu_id);
      }

      if (result == null) {
        await helper.insert(part_id, menu_id);
      }
    } finally {
      await helper.close();
    }
  }

  Future<void> deleteFromMenuId(menu_id) async {
    var helper = PartMenuDaoHelper(factory);
    try {
      await helper.open();
      await helper.deleteFromMenuId(menu_id);
    } finally {
      await helper.close();
    }
  }

  Future<List<Map>> getList({part_id, menu_id}) async {
    var helper = PartMenuDaoHelper(factory);
    var result;
    try {
      await helper.open();

      result = await helper.getList(part_id: part_id, menu_id: menu_id);
    } finally {
      await helper.close();
    }

    return result;
  }
}

class PartMenuDaoHelper {
  // テーブル
  static const tableName = 'parts_menus';
  static const columnPartId = 'part_id';
  static const columnMenuId = 'menu_id';

  final DbFactory _factory;
  late Database _db;

  PartMenuDaoHelper(this._factory);

  Future<void> insert(part_id, menu_id) async {
    await _db.insert(tableName, {
      columnPartId: part_id,
      columnMenuId: menu_id,
    });
  }

  Future<void> deleteFromMenuId(menu_id) async {
    await _db.delete(tableName,
        where: '$columnMenuId = ?',
        whereArgs: [menu_id]);
  }

  Future<Map?> fetch(int part_id, int menu_id) async {
    List<Map> maps = await _db.query(tableName,
        columns: [
          columnPartId,
          columnMenuId,
        ],
        where: '$columnPartId = ? AND $columnMenuId = ?',
        whereArgs: [part_id, menu_id]);

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<Map?>> getList({part_id, menu_id}) async {
    var where = '';
    var whereArgs = [];

    if (part_id != null) {
      where = '$columnPartId = ?';
      whereArgs.add(part_id);
    }

    if (menu_id != null) {
      if (where != '') {
        where += ' AND ';
      }
      where += '$columnMenuId = ?';
      whereArgs.add(menu_id);
    }

    return await _db.query(tableName,
        columns: [
          columnPartId,
          columnMenuId,
        ],
        where: where,
        whereArgs: whereArgs);
  }

  Future<void> close() async => _db.close();

  Future<void> open() async => _db = await _factory.create();
}
