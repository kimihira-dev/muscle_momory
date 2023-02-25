import 'package:muscle_memory/db/db_factory.dart';
import 'package:muscle_memory/db/part_dao.dart';
import 'package:muscle_memory/db/part_menu_dao.dart';
import 'package:muscle_memory/entity/menu.dart';
import 'package:muscle_memory/util.dart';
import 'package:sqflite/sqflite.dart';

import '../const.dart';

class MenuDao {
  final DbFactory factory;

  const MenuDao(this.factory);

  Future<void> save(Menu menu) async {
    var helper = MenuDaoHelper(factory);
    var partMenuDao = PartMenuDao(factory);
    try {
      await helper.open();

      var result;
      if (menu.id != null) {
        result = await helper.fetch(menu.id!);
      }

      // 新規登録
      if (result == null) {
        var menu_id = await helper.insert(menu);
        // 中間テーブル登録
        await Future.forEach(menu.parts, (part) async {
          await partMenuDao.save(part.id, menu_id);
        });
      }
      // 更新
      else {
        await helper.update(menu);
        // 中間テーブル登録
        await partMenuDao.deleteFromMenuId(menu.id);
        await Future.forEach(menu.parts, (part) async {
          await partMenuDao.save(part.id, menu.id);
        });
      }
    } finally {
      await helper.close();
    }
  }

  Future<List<Menu>> getList() async {
    var helper = MenuDaoHelper(factory);
    var partMenuDao = PartMenuDao(factory);
    var partDao = PartDao(factory);
    var result;
    try {
      await helper.open();

      result = await helper.getList();

      await Future.forEach(result, (Menu menu) async {
        var partMenus = await partMenuDao.getList(menu_id: menu.id);
        await Future.forEach(partMenus, (Map partMenu) async {
          menu.parts.add(
              await partDao.find(partMenu[PartMenuDaoHelper.columnPartId]));
        });
      });
    } finally {
      await helper.close();
    }

    return result;
  }
}

class MenuDaoHelper {
  // テーブル
  static const tableName = 'menus';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnType = 'type';
  static const columnWeightFlg = 'weight_flg';
  static const columnCountFlg = 'count_flg';
  static const columnTimeFlg = 'time_flg';
  static const columnCreateDate = 'create_at';
  static const columnUpdateDate = 'update_at';
  static const columns = [
    columnId,
    columnName,
    columnName,
    columnType,
    columnWeightFlg,
    columnCountFlg,
    columnTimeFlg,
    columnCreateDate,
    columnUpdateDate
  ];

  final DbFactory _factory;
  late Database _db;

  MenuDaoHelper(this._factory);

  Future<int> insert(Menu menu) async {
    var data = convertToMap(menu);
    // data[columnCreateDate] = 'datetime(now)';
    return await _db.insert(tableName, data);
  }

  Future<void> update(Menu menu) async {
    await _db.update(
        tableName,
        {
          columnName: menu.name,
          columnType: menu.type.id,
          columnWeightFlg: menu.weightFlg,
          columnCountFlg: menu.countFlg,
          columnTimeFlg: menu.timeFlg,
        },
        where: '$columnId = ?',
        whereArgs: [menu.id]);
  }

  Future<Menu?> fetch(int id) async {
    List<Map> maps = await _db.query(tableName,
        columns: columns, where: '$columnId = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return convertToEntity(maps.first);
    }
    return null;
  }

  Future<List<Menu>> getList() async {
    var result = <Menu>[];
    List<Map> maps = await _db.query(tableName, columns: columns);

    if (maps.isNotEmpty) {
      maps.forEach((element) {
        // 部位を取得
        result.add(convertToEntity(element));
      });
    }
    return result;
  }

  Menu convertToEntity(Map data) {
    return Menu(
        data[columnId],
        data[columnName],
        MenuType.fromId(data[columnType]),
        intToBool(data[columnWeightFlg]),
        intToBool(data[columnCountFlg]),
        intToBool(data[columnTimeFlg]), []);
  }

  Map<String, Object> convertToMap(Menu menu) {
    return {
      columnName: menu.name,
      columnType: menu.type.id,
      columnWeightFlg: menu.weightFlg,
      columnCountFlg: menu.countFlg,
      columnTimeFlg: menu.timeFlg,
    };
  }

  Future<void> close() async => _db.close();

  Future<void> open() async => _db = await _factory.create();
}
