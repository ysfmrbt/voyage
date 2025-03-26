import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class Home extends StatelessWidget {
  late SharedPreferences prefs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Page Home".toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () {
            _onDeconnecter(context);
          },
          child: Text(
            "Déconnexion",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: Size.fromHeight(50),
          ),
        ),
      ),
    );
  }

  Future<void> _onDeconnecter(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setBool("connecte", false);
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/inscription',
      (route) => false,
    );
  }
}
