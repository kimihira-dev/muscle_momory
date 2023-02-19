import 'package:flutter/material.dart';
import 'package:muscle_memory/db/part_dao.dart';
import 'package:muscle_memory/entity/part.dart';
import 'package:muscle_memory/page/menu_list_page.dart';

import '../db/db_factory.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final _factory = DbFactory();
  late List<Part> partList = [];

  _HomePageState() {
    _updateList();
  }

  Future<void> _updateList() async {
    partList = await PartDao(_factory).getList();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: () {
            _factory.reCreate();
            _updateList();
          }, icon: Icon(Icons.abc_sharp)),
          IconButton(onPressed: () {
            _factory.create();
          }, icon: Icon(Icons.adb_outlined))
        ],
      ),
      body: ListView.builder(
          itemCount: partList.length,
          itemBuilder: (context, index) {
            return Column(children: [
              ListTile(
                title: Text(partList[index].name ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)  => MenuListPage(partList[index])));
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