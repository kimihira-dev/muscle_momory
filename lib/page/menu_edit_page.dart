import 'package:flutter/material.dart';
import 'package:muscle_memory/const.dart';
import 'package:muscle_memory/db/db_factory.dart';
import 'package:muscle_memory/db/menu_dao.dart';
import 'package:muscle_memory/db/part_dao.dart';
import 'package:muscle_memory/entity/menu.dart';

import '../entity/part.dart';

class MenuEditPage extends StatefulWidget {
  final Menu? menu;
  final int? partId;
  final void Function() updateList;

  const MenuEditPage(this.updateList, {super.key, this.menu, this.partId});

  @override
  State<MenuEditPage> createState() => _MenuEditPageState(this.partId, this.menu);
}

class _MenuEditPageState extends State<MenuEditPage> {
  final _factory = DbFactory();
  late MenuDao _menuDao;
  late List<Part> _partList = [];

  late Menu _menu;
  String _title = '';
  String _mode_name = '';
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();

  // Formの値
  var menu_name = '';
  var typeIndex = MenuType.free.index;
  final List<int> _partIndexes = [];

  _MenuEditPageState(partId, menu) {
    _menuDao = MenuDao(_factory);

    if (menu == null) {
      _title = '新規メニュー追加';
      _mode_name = '登録';
      _menu = Menu.empty();
    } else {
      _title = 'メニュー編集';
      _mode_name = '更新';
      _menu = menu;
    }
    menu_name = _menu.name;
    typeIndex = _menu.type.index;

    _getPartList(partId);
  }

  /// 部位を取得
  Future<void> _getPartList(partId) async {
    _partList = await PartDao(_factory).getList();

    // 初期選択
    _partList.asMap().forEach((key, Part part) {
      if (_menu.id != null) {
        for (var element in _menu.parts) {
          if (element.id == part.id) {
            _partIndexes.add(key);
            break;
          }
        }
        ;
      } else {
        if (part.id == partId) {
          _partIndexes.add(key);
        }
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var body;
    if (_partList.isNotEmpty) {
      body = Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: menu_name,
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
                  MenuType.values.length,
                  (int index) {
                    return ChoiceChip(
                      label: Text(MenuType.values[index].name),
                      selectedColor: Colors.green,
                      selected: typeIndex == index,
                      onSelected: (bool selected) {
                        setState(() {
                          typeIndex = index;
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
                      selected: () {
                        return _partIndexes.contains(index);
                      }(),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _partIndexes.add(index);
                          } else {
                            if (_partIndexes.length > 1) {
                              _partIndexes.remove(index);
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                    content: Text('１つ以上の部位を選択してください。'),
                              backgroundColor: Colors.red.shade300,));
                            }
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
                    if (_partIndexes.length == 0) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(
                        content: Text('１つ以上の部位を選択してください。'),
                        backgroundColor: Colors.red.shade300,));
                    } else {
                      // 登録
                      _menu.name = menu_name;
                      _menu.type = MenuType.values[typeIndex];
                      _menu.parts.clear();
                      _partIndexes.forEach(
                              (element) => _menu.parts.add(_partList[element]));
                      await _menuDao.save(_menu);
                      // 一覧画面更新
                      widget.updateList();
                      // 一覧に戻る
                      Navigator.pop(context);
                      // メッセージ
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('$_mode_nameしました')));
                    }
                  }
                },
                child: Text(_mode_name),
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
