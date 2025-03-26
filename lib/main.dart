import 'package:flutter/material.dart';
import 'package:voyage/pages/inscription.page.dart';
import 'package:voyage/pages/home.page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final routes = {
    '/home': (context) => Home(),
    '/inscription': (context) => InscriptionPage(),
  };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: routes,
      home: InscriptionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
