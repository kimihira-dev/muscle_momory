import 'package:muscle_memory/db/db_factory.dart';
import 'package:sqflite/sqflite.dart';

import '../entity/part.dart';

class PartDao {
  final DbFactory factory;

  const PartDao(this.factory);

  Future<Part> find(id) async {
    var helper = PartDaoHelper(factory);
    var result;
    try {
      await helper.open();

      result = await helper.fetch(id);
    } finally {
      await helper.close();
    }

    return result;
  }

  Future<List<Part>> getList() async {
    var helper = PartDaoHelper(factory);
    var result = <Part>[];
    try {
      await helper.open();

      result = await helper.getList();
    } finally {
      await helper.close();
    }

    return result;
  }
}

class PartDaoHelper {
  static const tableName = 'parts';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnRecoveryTime = 'recovery_time';
  static const columnCreateDate = 'create_at';
  static const columnUpdateDate = 'update_at';

  static const columns = [
    columnId, columnName, columnRecoveryTime, columnCreateDate, columnUpdateDate
  ];

  final DbFactory _factory;
  late Database _db;

  PartDaoHelper(this._factory);

  Future<Part?> fetch(int id) async {
    List<Map> maps = await _db.query(tableName, columns: columns,
        where:  '$columnId = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return convertToEntity(maps.first);
    }
    return null;
  }

  Future<List<Part>> getList() async {
    var result = <Part>[];
    List<Map> maps = await _db.query(tableName, columns: columns);

    if (maps.isNotEmpty) {
      maps.forEach((element) {
        result.add(convertToEntity(element));
      });
    }

    return result;
  }

  Part convertToEntity(Map data) {
    return Part(
      data[columnId],
      data[columnName],
      data[columnRecoveryTime],
      DateTime.parse(data[columnCreateDate]),
      DateTime.parse(data[columnUpdateDate]),
    );
  }

  Future<void> close() async => _db.close();

  Future<void> open() async => _db = await _factory.create();
}
