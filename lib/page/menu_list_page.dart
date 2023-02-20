import 'package:flutter/material.dart';
import 'package:muscle_memory/db/menu_dao.dart';
import 'package:muscle_memory/page/menu_edit_page.dart';
import 'package:muscle_memory/entity/part.dart';

import '../db/db_factory.dart';
import '../entity/menu.dart';

class MenuListPage extends StatefulWidget {
  final Part part;

  const MenuListPage(this.part, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  late List<Menu> menuList = [];

  _MenuListPageState() {
    _updateList();
  }

  Future<void> _updateList() async {
    DbFactory factory = DbFactory();
    menuList = await MenuDao(factory).getList();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.part.name),
        actions: [
          IconButton(
              onPressed: () {
                // メニュー追加画面へ
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MenuEditPage(_updateList, partId: widget.part.id,)));
              },
              icon: Icon(Icons.add)),
        ],
      ),
      body: ListView.builder(
          itemCount: menuList.length,
          itemBuilder: (context, index) {
            return Column(children: [
              ListTile(
                title: Text(menuList[index].name),
                onTap: () {
                },
                trailing: IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)  => MenuEditPage(_updateList, menu: menuList[index], partId: widget.part.id)));
                  },
                  icon: Icon(Icons.edit),
                ),
              ),
              const Divider(
                height: 0,
              ),
            ]);
          }),
    );
  }
}
