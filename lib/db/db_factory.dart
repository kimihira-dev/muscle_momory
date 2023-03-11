import 'package:muscle_memory/db/menu_dao.dart';
import 'package:muscle_memory/db/part_dao.dart';
import 'package:muscle_memory/db/part_menu_dao.dart';
import 'package:muscle_memory/db/workout_log_dao.dart';
import 'package:muscle_memory/db/workout_log_set_dao.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbFactory {
  static const APP_NAME = 'muscle_memory';
  static const DB_NAME = APP_NAME + '.db';

  Future<Database> create() async {
    var databasePath = await getDatabasesPath();
    final path = join(databasePath, DB_NAME);

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
      create table ${PartDaoHelper.tableName} (
        ${PartDaoHelper.columnId} integer primary key autoincrement,
        ${PartDaoHelper.columnName} text,
        ${PartDaoHelper.columnRecoveryTime} int,
        ${PartDaoHelper.columnCreateDate} TIMESTAMP DEFAULT (datetime(CURRENT_TIMESTAMP)),
        ${PartDaoHelper.columnUpdateDate} TIMESTAMP DEFAULT (datetime(CURRENT_TIMESTAMP))
        );
      ''');
      await db.execute(generateUpdateTriggerSQL(PartDaoHelper.tableName));
      await db.execute('''
      create table ${MenuDaoHelper.tableName} (
        ${MenuDaoHelper.columnId} integer primary key autoincrement,
        ${MenuDaoHelper.columnName} text,
        ${MenuDaoHelper.columnType} int,
        ${MenuDaoHelper.columnWeightFlg} boolean,
        ${MenuDaoHelper.columnCountFlg} boolean,
        ${MenuDaoHelper.columnTimeFlg} boolean,
        ${MenuDaoHelper.columnCreateDate} TIMESTAMP DEFAULT (datetime(CURRENT_TIMESTAMP)),
        ${MenuDaoHelper.columnUpdateDate} TIMESTAMP DEFAULT (datetime(CURRENT_TIMESTAMP))
        );
      ''');
      await db.execute(generateUpdateTriggerSQL(MenuDaoHelper.tableName));
      await db.execute('''
      create table ${PartMenuDaoHelper.tableName} (
        ${PartMenuDaoHelper.columnPartId} integer,
        ${PartMenuDaoHelper.columnMenuId} integer,
        PRIMARY KEY (${PartMenuDaoHelper.columnPartId}, ${PartMenuDaoHelper.columnMenuId}),
        FOREIGN KEY (${PartMenuDaoHelper.columnPartId}) 
          REFERENCES ${PartDaoHelper.tableName}(${PartDaoHelper.columnId}),
        FOREIGN KEY (${PartMenuDaoHelper.columnMenuId}) 
          REFERENCES ${MenuDaoHelper.tableName}(${MenuDaoHelper.columnId})
        );
      ''');
      await db.execute('''
      create table ${WorkoutLogDaoHelper.tableName} (
        ${WorkoutLogDaoHelper.columnId} integer primary key autoincrement,
        ${WorkoutLogDaoHelper.columnMenuId} integer,
        ${WorkoutLogDaoHelper.columnCreateDate} TIMESTAMP DEFAULT (datetime(CURRENT_TIMESTAMP)),
        ${WorkoutLogDaoHelper.columnUpdateDate} TIMESTAMP DEFAULT (datetime(CURRENT_TIMESTAMP)),
        FOREIGN KEY (${WorkoutLogDaoHelper.columnMenuId}) 
          REFERENCES ${MenuDaoHelper.tableName}(${MenuDaoHelper.columnId})
        );
      ''');
      await db.execute(generateUpdateTriggerSQL(WorkoutLogDaoHelper.tableName));
      await db.execute('''
      create table ${WorkoutLogSetDaoHelper.tableName} (
        ${WorkoutLogSetDaoHelper.columnId}  integer primary key autoincrement,
        ${WorkoutLogSetDaoHelper.columnWorkoutLogId} integer,
        ${WorkoutLogSetDaoHelper.columnWeight} REAL,
        ${WorkoutLogSetDaoHelper.columnCount} INTEGER,
        ${WorkoutLogSetDaoHelper.columnTime} INTEGER,
        ${WorkoutLogSetDaoHelper.columnBodyWight} REAL,
        ${WorkoutLogSetDaoHelper.columnCreateDate} TIMESTAMP DEFAULT (datetime(CURRENT_TIMESTAMP)),
        ${WorkoutLogSetDaoHelper.columnUpdateDate} TIMESTAMP DEFAULT (datetime(CURRENT_TIMESTAMP)),
        FOREIGN KEY (${WorkoutLogSetDaoHelper.columnWorkoutLogId}) 
          REFERENCES ${WorkoutLogDaoHelper.tableName}(${WorkoutLogDaoHelper.columnId})
        );
      ''');
      await db.execute(generateUpdateTriggerSQL(WorkoutLogSetDaoHelper.tableName));

      await db.execute('''
        INSERT INTO ${PartDaoHelper.tableName}
        (${PartDaoHelper.columnName}, ${PartDaoHelper.columnRecoveryTime})
        VALUES
         ('胸', 3),
         ('肩', 2),
         ('脚', 3)
       ;
      ''');
    });
  }

  String generateUpdateTriggerSQL(tableName) {
    return '''
      CREATE TRIGGER tri_update_$tableName AFTER UPDATE ON $tableName 
      BEGIN
        UPDATE $tableName SET update_at = datetime(CURRENT_TIMESTAMP);
      END;
      ''';
  }

  Future<Database> reCreate() async {
    var databasePath = await getDatabasesPath();
    final path = join(databasePath, DB_NAME);
    await deleteDatabase(path);

    return await create();
  }
}
