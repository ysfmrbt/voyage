import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voyage/pages/authentification.page.dart';
import 'package:voyage/pages/inscription.page.dart';
import 'package:voyage/pages/home.page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final routes = {
    '/home': (context) => Home(),
    '/inscription': (context) => InscriptionPage(),
    '/authentification': (context) => AuthentificiationPage(),
  };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: routes,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            bool c = snapshot.data?.getBool('connecte') ?? false;
            if (c) return Home();
          }
          return InscriptionPage();
        },
      ),
    );
  }
}
