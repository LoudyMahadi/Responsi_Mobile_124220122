import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsi_124220122/pages/favorite.dart';
import 'package:responsi_124220122/pages/list.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('favoritesBox');
  await Hive.openBox('amiiboBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amiibo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AmiiboListPage(),
      routes: {
        '/favorites': (context) => FavoritesPage(),
      },
    );
  }
}
