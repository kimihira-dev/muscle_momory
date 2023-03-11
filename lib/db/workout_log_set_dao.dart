import 'package:muscle_memory/db/db_factory.dart';
import 'package:sqflite/sqflite.dart';

import '../entity/workout_log_set.dart';

class WorkoutLogSetDao {
  final DbFactory factory;

  const WorkoutLogSetDao(this.factory);

  Future<void> save(WorkoutLogSet workoutLogSet) async {
    var helper = WorkoutLogSetDaoHelper(factory);
    try {
      await helper.open();

      var result;
      if (workoutLogSet.id != null) {
        result = await helper.fetch(workoutLogSet.id!);
      }

      // 新規登録
      if (result == null) {
        await helper.insert(workoutLogSet);
      }
      // 更新
      else {
        await helper.update(workoutLogSet);
      }
    } finally {
      await helper.close();
    }
  }

  Future<List<WorkoutLogSet>> getList(int workoutLogId) async {
    var helper = WorkoutLogSetDaoHelper(factory);
    var result;
    try {
      await helper.open();
      result = await helper.getList(workoutLogId);
    } finally {
      await helper.close();
    }

    return result;
  }

  Future<void> delete(WorkoutLogSet workoutLogSet) async {
    var helper = WorkoutLogSetDaoHelper(factory);
    try {
      await helper.open();
      await helper.delete(workoutLogSet);
    } finally {
      await helper.close();
    }
  }
}

class WorkoutLogSetDaoHelper {
  // テーブル
  static const tableName = 'workout_log_sets';
  static const columnId = 'id';
  static const columnWorkoutLogId = 'workout_log_id';
  static const columnWeight = 'weight';
  static const columnCount = 'count';
  static const columnTime = 'time';
  static const columnBodyWight = 'bodyWight';
  static const columnCreateDate = 'create_at';
  static const columnUpdateDate = 'update_at';
  static const columns = [
    columnWorkoutLogId,
    columnId,
    columnWeight,
    columnCount,
    columnTime,
    columnBodyWight,
    columnCreateDate,
    columnUpdateDate,
  ];

  final DbFactory _factory;
  late Database _db;

  WorkoutLogSetDaoHelper(this._factory);

  Future<int> insert(WorkoutLogSet entity) async {
    var data = convertToMap(entity);
    return await _db.insert(tableName, data);
  }

  Future<void> update(WorkoutLogSet entity) async {
    await _db.update(tableName, convertToMap(entity),
        where: '$columnId = ?', whereArgs: [entity.id]);
  }

  Future<void> delete(WorkoutLogSet entity) async {
    await _db.delete(tableName, where: '$columnId = ?', whereArgs: [entity.id]);
  }

  Future<void> deleteFromWorkoutLogId(int workoutLogId) async {
    await _db.delete(tableName,
        where: '$columnWorkoutLogId = ?', whereArgs: [workoutLogId]);
  }

  Future<WorkoutLogSet?> fetch(int id) async {
    List<Map> maps = await _db.query(tableName,
        columns: columns, where: '$columnId = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return convertToEntity(maps.first);
    }
    return null;
  }

  Future<List<WorkoutLogSet>> getList(int workoutLogId) async {
    var result = <WorkoutLogSet>[];
    List<Map> maps = await _db.query(tableName,
        columns: columns,
        where: '$columnWorkoutLogId = ?',
        whereArgs: [workoutLogId],
        orderBy: '$columnWorkoutLogId, $columnId');

    if (maps.isNotEmpty) {
      maps.forEach((data) {
        result.add(convertToEntity(data));
      });
    }
    return result;
  }

  WorkoutLogSet convertToEntity(Map data) {
    return WorkoutLogSet(
        data[columnWorkoutLogId],
        data[columnId],
        data[columnWeight],
        data[columnCount],
        data[columnTime],
        data[columnBodyWight],
        DateTime.parse(data[columnCreateDate]),
        DateTime.parse(data[columnUpdateDate]));
  }

  Map<String, Object?> convertToMap(WorkoutLogSet entity) {
    return {
      columnWorkoutLogId: entity.workoutLogId,
      columnWeight: entity.weight,
      columnCount: entity.count,
      columnTime: entity.time,
      columnBodyWight: entity.bodyWight,
    };
  }

  Future<void> close() async => _db.close();

  Future<void> open() async => _db = await _factory.create();
}
