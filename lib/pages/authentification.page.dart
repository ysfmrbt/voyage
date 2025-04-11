import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class AuthentificiationPage extends StatelessWidget {
  TextEditingController txt_login = new TextEditingController();
  TextEditingController txt_password = new TextEditingController();
  late SharedPreferences prefs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Page Authentification".toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Entrer votre email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 2),
                ),
              ),
              controller: txt_login,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: "Mot de passe",
                hintText: "Entrer votre password",
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 2),
                ),
              ),
              controller: txt_password,
              obscureText: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                _onAuthentifier(context); // _ car private
              },
              child: Text(
                "Authentifier",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size.fromHeight(50),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/inscription');
              },
              child: Text(
                "Inscription",
                style: TextStyle(color: Colors.blue, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAuthentifier(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    if (txt_login.text.isNotEmpty && txt_password.text.isNotEmpty) {
      if (txt_login.text == prefs.getString("login") &&
          txt_password.text == prefs.getString("password")) {
        prefs.setBool("connecte", true);
        Navigator.pushNamed(context, '/home');
      } else {
        const snackBar = SnackBar(
          content: Text('Email ou mot de passe incorrect'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      const snackBar = SnackBar(
        content: Text('Veuillez remplir tous les champs'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
