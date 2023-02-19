import 'package:flutter/material.dart';
import 'package:muscle_memory/const.dart';
import 'package:muscle_memory/db/db_factory.dart';
import 'package:muscle_memory/db/menu_dao.dart';
import 'package:muscle_memory/db/part_dao.dart';
import 'package:muscle_memory/entity/menu.dart';

import '../entity/part.dart';

class MenuEdit extends StatefulWidget {
  final String? menuId;
  final int? partId;
  final void Function() updateList;

  const MenuEdit(this.updateList, {super.key, this.menuId, this.partId});

  @override
  State<MenuEdit> createState() => _MenuEditState(this.partId, this.menuId);
}

class _MenuEditState extends State<MenuEdit> {

  final _factory = DbFactory();
  late MenuDao _menuDao;
  late List<Part> _partList = [];

  late Menu _menu;
  String _title = '';
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();

  // Form関連
  var menu_name = '';
  var workoutUnitIndex = WorkoutUnit.kg.index;
  List<int> _partIndexes = [];


  _MenuEditState(partId, menuId) {
    if (menuId == null) {
      _title = "新規メニュー追加";
      _menu = Menu.empty();
    } else {
      _title = "編集";
    }
    _menuDao = MenuDao(_factory);
    _getPartList(partId);
  }

  /// 部位を取得
  Future<void> _getPartList(partId) async {
    _partList = await PartDao(_factory).getList();
    // 初期選択
    _partList.asMap().forEach((key, Part part){
      if (part.id == partId) {
        _partIndexes.add(key);
      }
    });
    setState(() {
    });
  }



  @override
  Widget build(BuildContext context) {
    var body = null;
    if (_partList.isNotEmpty) {
      body = Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '名前'),
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return '必須です';
                  }
                  return null;
                },
                onChanged: (value) {
                  menu_name = value;
                },
              ),
              Text('単位'),
              Wrap(
                // list of length 3
                children: List.generate(
                  WorkoutUnit.values.length,
                      (int index) {
                    return ChoiceChip(
                      label: Text(WorkoutUnit.values[index].name),
                      selectedColor: Colors.green,
                      // selected chip value
                      selected: workoutUnitIndex == index,
                      // onselected method
                      onSelected: (bool selected) {
                        setState(() {
                          workoutUnitIndex = index;
                        });
                      },
                    );
                  },
                ).toList(),
              ),
              Text('部位'),
              Wrap(
                children: List.generate(
                  _partList.length,
                      (int index) {
                    return ChoiceChip(
                      label: Text(_partList[index].name),
                      selectedColor: Colors.green,
                      // selected chip value
                      selected: () {
                        return _partIndexes.contains(index);
                      }(),
                      // onselected method
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _partIndexes.add(index);
                          } else {
                            _partIndexes.remove(index);
                          }
                        });
                      },
                    );
                  },
                ).toList(),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // 登録
                    _menu.name = menu_name;
                    _menu.workOutUnit = WorkoutUnit.values[workoutUnitIndex];
                    _partIndexes.forEach((element) => _menu.parts.add(_partList[element]));
                    await _menuDao.save(_menu);
                    widget.updateList();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('登録しました')));
                  }
                },
                child: const Text('登録'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_title),
      ),
      body: body,
    );
  }
}
