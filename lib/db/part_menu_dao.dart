import 'package:muscle_memory/db/db_factory.dart';
import 'package:muscle_memory/entity/menu.dart';
import 'package:sqflite/sqflite.dart';

import '../const.dart';

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

  // Future<List<Menu>> getList() async {
  //   var helper = PartMenuDaoHelper(factory);
  //   var result;
  //   try {
  //     await helper.open();
  //
  //     result = await helper.getList();
  //   } catch (e) {
  //     print(e.toString());
  //   } finally {
  //     await helper.close();
  //   }
  //
  //   return result;
  // }
}

class PartMenuDaoHelper {
  // テーブル
  static const tableName = 'part_menu';
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



  Future<Map?> fetch(int part_id, int menu_id) async {
    List<Map> maps = await _db.query(tableName, columns: [
      columnPartId,
      columnMenuId,
    ],
        where:  '$columnPartId = ? AND $columnMenuId = ?',
        whereArgs: [part_id, menu_id]);

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
  //
  // Future<List<Menu>> getList() async {
  //   var result = <Menu>[];
  //   List<Map> maps = await _db.query(tableName, columns: [
  //     columnId,
  //     columnName,
  //   ]);
  //
  //   if (maps.isNotEmpty) {
  //     maps.forEach((element) {
  //       result.add(Menu(element[columnId], element[columnName], WorkoutUnit.kg));
  //     });
  //   }
  //   return result;
  // }

  Future<void> close() async => _db.close();
  Future<void> open() async => _db = await _factory.create();
}
