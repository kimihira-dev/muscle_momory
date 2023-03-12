import 'package:flutter/material.dart';
import 'package:muscle_memory/db/workout_log_dao.dart';
import 'package:muscle_memory/entity/workout_log.dart';
import 'package:muscle_memory/page/workout_page.dart';

import '../db/db_factory.dart';
import '../entity/menu.dart';
import '../util.dart';

class HistoryPage extends StatefulWidget {
  final Menu _menu;

  const HistoryPage(this._menu, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HistoryPageState(_menu);
}

class _HistoryPageState extends State<HistoryPage> {
  late List<WorkoutLog> _workoutLogList = [];
  final Menu _menu;

  _HistoryPageState(this._menu) {
    _updateList();
  }

  Future<void> _updateList() async {
    var factory = DbFactory();
    try {
      _workoutLogList = await WorkoutLogDao(factory).getList(menu_id: _menu.id);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
        content: Text('データの取得に失敗しました。'),
        backgroundColor: Colors.red.shade300,));
      rethrow;
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_menu.name  + '履歴'),
      ),
      body: ListView.builder(
          itemCount: _workoutLogList.length,
          itemBuilder: (context, index) {
            return Column(children: [
              ListTile(
                title: Text(formatDate(_workoutLogList[index].createDate!)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)  => WorkoutPage(_menu, workoutLog: _workoutLogList[index])));
                },
              ),
              const Divider(
                height: 0,
              ),
            ]);
          }),
    );
  }
}
