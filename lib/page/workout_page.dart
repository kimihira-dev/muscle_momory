import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muscle_memory/db/db_factory.dart';
import 'package:muscle_memory/db/workout_log_dao.dart';
import 'package:muscle_memory/db/workout_log_set_dao.dart';
import 'package:muscle_memory/entity/menu.dart';
import 'package:muscle_memory/entity/workout_log_set.dart';
import 'package:muscle_memory/input/decimal_text_input_formatter.dart';

import '../entity/workout_log.dart';
import '../util.dart';
import 'hisotry_page.dart';

class WorkoutPage extends StatefulWidget {
  final Menu menu;
  final WorkoutLog? workoutLog;

  const WorkoutPage(this.menu, {super.key, this.workoutLog});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState(menu, workoutLog: workoutLog);
}

class _WorkoutPageState extends State<WorkoutPage> {
  final _scaffoldKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  final Menu _menu;
  var workoutLog;
  var _workoutLogSetList;
  WorkoutLogSet? _editWorkoutLogSet;
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final _factory = DbFactory();
  late WorkoutLogDao _workoutLogDao;
  late WorkoutLogSetDao _workoutLogSetDao;

  _WorkoutPageState(this._menu, {this.workoutLog}) {
    _workoutLogDao = WorkoutLogDao(_factory);
    _workoutLogSetDao = WorkoutLogSetDao(_factory);
    _init();
  }

  Future<void> _init() async {
    var tmpWorkoutLog;
    if (workoutLog == null) {
      tmpWorkoutLog = await _workoutLogDao.findLatest(_menu.id!);
    }

    if (tmpWorkoutLog != null &&
        isSameDay(tmpWorkoutLog.createDate!, DateTime.now())) {
      workoutLog = tmpWorkoutLog;
    }
    await getWorkoutLogSet();
  }

  Future<void> getWorkoutLogSet() async {
    if (workoutLog != null) {
      _workoutLogSetList = await _workoutLogSetDao.getList(workoutLog.id);
    } else {
      _workoutLogSetList = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var body;
    if (_workoutLogSetList != null) {
      // 入力フォーム
      var inputRow = Row(children: []);
      if (_menu.weightFlg) {
        inputRow.children.add(Expanded(
          child: TextFormField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [DecimalTextInputFormatter()],
            controller: _weightController,
            validator: (value) {
              if (value != null && value.isEmpty) {
                return '必須です';
              }
              return null;
            },
          ),
        ));
        inputRow.children.add(Text('Kg'));
      }
      if (_menu.countFlg) {
        inputRow.children.add(Expanded(
          child: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 4,
            controller: _countController,
            decoration: InputDecoration(
              counterText: '',
            ),
            validator: (value) {
              if (value != null && value.isEmpty) {
                return '必須です';
              } else if (int.parse(value!) <= 0) {
                return '0以上';
              }
              return null;
            },
          ),
        ));
        inputRow.children.add(Text('回'));
      }

      inputRow.children.add(Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
          width: 48,
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(16.0),
              ),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: IconButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // 新規ログを登録
                  if (workoutLog == null) {
                    workoutLog = WorkoutLog.empty(_menu.id!);
                    var workoutLog_id = await _workoutLogDao.save(workoutLog);
                    workoutLog = await _workoutLogDao.find(workoutLog_id);
                  }
                  // セットを登録
                  var workoutLogSet;
                  if (_editWorkoutLogSet != null) {
                    workoutLogSet = _editWorkoutLogSet;
                    _editWorkoutLogSet = null;
                  } else {
                    workoutLogSet = WorkoutLogSet.empty(workoutLog.id);
                  }

                  workoutLogSet.weight = double.parse(_weightController.text);
                  workoutLogSet.count = int.parse(_countController.text);
                  await _workoutLogSetDao.save(workoutLogSet);
                  // リストを更新
                  await getWorkoutLogSet();
                }
              },
              icon: Icon(
                Icons.add,
                size: 28,
              ),
            ),
          ),
        ),
      ));

      body = Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: _workoutLogSetList.length,
                  itemBuilder: (context, index) {
                    return Column(children: [
                      ListTile(
                        title: (WorkoutLogSet workoutLogSet) {
                          var displayText = (index + 1).toString() + '：';
                          if (workoutLogSet.weight != null) {
                            displayText +=
                                workoutLogSet.weight.toString() + ' kg';
                          }
                          if (workoutLogSet.count != null) {
                            if (displayText.isNotEmpty) {
                              displayText += '/';
                            }
                            displayText +=
                                workoutLogSet.count.toString() + ' 回';
                          }
                          return Text(displayText);
                        }(_workoutLogSetList[index]),
                        selected: _editWorkoutLogSet == _workoutLogSetList[index],
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _editWorkoutLogSet =
                                      _workoutLogSetList[index];
                                });
                                _countController.text =
                                    _editWorkoutLogSet!.count.toString();
                                _weightController.text =
                                    _editWorkoutLogSet!.weight.toString();
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () async {
                                await _workoutLogSetDao
                                    .delete(_workoutLogSetList[index]);
                                // リストを更新
                                await getWorkoutLogSet();
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 0,
                      ),
                    ]);
                  }),
            ),
            Form(key: _formKey, child: inputRow),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(_menu.name),
        actions: [
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)  => HistoryPage(_menu)));
          }, icon: Icon(Icons.history)),
        ],
      ),
      body: body,
    );
  }
}
