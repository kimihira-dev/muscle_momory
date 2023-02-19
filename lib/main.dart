import 'package:flutter/material.dart';
import 'package:muscle_memory/db/part_dao.dart';
import 'package:muscle_memory/entity/part.dart';
import 'package:muscle_memory/page/home_page.dart';
import 'package:muscle_memory/page/menu_list_page.dart';

import 'db/db_factory.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muscle Memory',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(title: 'Muscle Memory'),
    );
  }
}




