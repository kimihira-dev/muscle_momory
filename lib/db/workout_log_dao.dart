import 'package:muscle_memory/db/db_factory.dart';
import 'package:muscle_memory/entity/menu.dart';
import 'package:sqflite/sqflite.dart';

import '../entity/workout_log.dart';
import '../util.dart';

class WorkoutLogDao {
  final DbFactory factory;

  const WorkoutLogDao(this.factory);

  Future<int?> save(WorkoutLog workoutLog) async {
    var result;
    var helper = WorkoutLogDaoHelper(factory);
    try {
      await helper.open();

      var data;
      if (workoutLog.id != null) {
        data = await helper.fetch(workoutLog.id!);
      }

      // 新規登録
      if (data == null) {
        result = await helper.insert(workoutLog);
      }
      // 更新
      else {
        await helper.update(workoutLog);
      }
    } finally {
      await helper.close();
    }

    return result;
  }

  Future<List<WorkoutLog>> getList({int? menu_id}) async {
    var helper = WorkoutLogDaoHelper(factory);
    var result;
    try {
      await helper.open();
      result = await helper.getList(menu_id);
    } finally {
      await helper.close();
    }

    return result;
  }

  Future<WorkoutLog> find(id) async {
    var helper = WorkoutLogDaoHelper(factory);
    var result;
    try {
      await helper.open();

      result = await helper.fetch(id);
    } finally {
      await helper.close();
    }

    return result;
  }

  Future<WorkoutLog?> findLatest(int menu_id) async {
    var helper = WorkoutLogDaoHelper(factory);
    var result;
    try {
      await helper.open();

      result = await helper.fetchLatest(menu_id);
    } finally {
      await helper.close();
    }

    return result;
  }
}

class WorkoutLogDaoHelper {
  // テーブル
  static const tableName = 'workout_logs';
  static const columnId = 'id';
  static const columnMenuId = 'menu_id';
  static const columnCreateDate = 'create_at';
  static const columnUpdateDate = 'update_at';
  static const columns = [
    columnId,
    columnMenuId,
    columnCreateDate,
    columnUpdateDate
  ];

  final DbFactory _factory;
  late Database _db;

  WorkoutLogDaoHelper(this._factory);

  Future<int> insert(WorkoutLog entity) async {
    var data = convertToMap(entity);
    return await _db.insert(tableName, data);
  }

  Future<void> update(WorkoutLog entity) async {
    await _db.update(tableName, convertToMap(entity),
        where: '$columnId = ?', whereArgs: [entity.id]);
  }

  Future<WorkoutLog?> fetch(int id) async {
    List<Map> maps = await _db.query(tableName,
        columns: columns, where: '$columnId = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return convertToEntity(maps.first);
    }
    return null;
  }

  Future<WorkoutLog?> fetchLatest(int menu_id) async {
    List<Map> maps = await _db.query(tableName,
        columns: columns,
        where: '$columnMenuId = ?',
        whereArgs: [menu_id],
        orderBy: '$columnId DESC',
        limit: 1);

    if (maps.isNotEmpty) {
      return convertToEntity(maps.first);
    }
    return null;
  }

  Future<List<WorkoutLog>> getList(int? menu_id) async {
    var result = <WorkoutLog>[];

    var where = '';
    var whereArgs = [];
    if (menu_id != null) {
      where += '$columnMenuId = ?';
      whereArgs.add(menu_id);
    }
    List<Map> maps = await _db.query(tableName,
        columns: convertSelectColumns(columns), where: where, whereArgs: whereArgs, orderBy: 'id DESC');

    if (maps.isNotEmpty) {
      maps.forEach((data) {
        result.add(convertToEntity(data));
      });
    }
    return result;
  }

  WorkoutLog convertToEntity(Map data) {
    return WorkoutLog(
        data[columnId],
        data[columnMenuId],
        DateTime.parse(data[columnCreateDate]),
        DateTime.parse(data[columnUpdateDate]));
  }

  Map<String, Object> convertToMap(WorkoutLog entity) {
    return {
      columnMenuId: entity.menuId,
    };
  }

  Future<void> close() async => _db.close();

  Future<void> open() async => _db = await _factory.create();
}
