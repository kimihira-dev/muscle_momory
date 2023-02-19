import 'package:muscle_memory/db/db_factory.dart';
import 'package:muscle_memory/entity/menu.dart';
import 'package:sqflite/sqflite.dart';

import '../entity/part.dart';

class PartDao {
  final DbFactory factory;

  const PartDao(this.factory);

  // Future<void> save(int? id, String name) async {
  //   var helper = MenuDaoHelper(factory);
  //   try {
  //     await helper.open();
  //
  //     var result;
  //     if (id != null) {
  //       result = await helper.fetch(id);
  //     }
  //
  //     if (result == null) {
  //       await helper.insert(name);
  //     }
  //   } finally {
  //     await helper.close();
  //   }
  // }

  Future<List<Part>> getList() async {
    var helper = PartDaoHelper(factory);
    var result = <Part>[];
    try {
      await helper.open();

      result = await helper.getList();
    } catch (e) {
      print(e.toString());
    } finally {
      await helper.close();
    }

    return result;
  }
}

class PartDaoHelper {
  static const tableName = 'part';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnRecoveryTime = 'recovery_time';
  static const columnCreateDate = 'create_date';
  static const columnUpdateDate = 'update_date';

  static const cloumns = [
    columnId, columnName, columnRecoveryTime, columnCreateDate, columnUpdateDate
  ];

  final DbFactory _factory;
  late Database _db;

  PartDaoHelper(this._factory);

  Future<void> open() async {
    _db = await _factory.create();
  }

  Future<Part?> fetch(int id) async {
    List<Map> maps = await _db.query(tableName, columns: cloumns,
        where:  '$columnId = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Part(
        maps.first[columnId],
        maps.first[columnName],
        maps.first[columnRecoveryTime],
        maps.first[columnCreateDate],
        maps.first[columnUpdateDate],
      );
    }
    return null;
  }

  Future<List<Part>> getList() async {
    var result = <Part>[];
    List<Map> maps = await _db.query(tableName, columns: cloumns);

    if (maps.isNotEmpty) {
      maps.forEach((element) {
        result.add(Part(
          element[columnId],
          element[columnName],
          element[columnRecoveryTime],
          element[columnCreateDate],
          element[columnUpdateDate],
        ));
      });
    }

    return result;
  }

  // Future<void> insert(String name) async {
  //   await _db.insert(tableName, {
  //     columnName: name
  //   });
  // }

  Future<void> close() async => _db.close();
}
