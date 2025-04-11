import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class Home extends StatelessWidget {
  late SharedPreferences prefs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
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

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.white, Colors.blue])
            ),
            child: Center(
              child: CircleAvatar(
                backgroundImage: AssetImage("images/profil.jpg"),
                radius: 80,
              )
            ),
          ),
          ListTile(
            title: Text("Accueil", style: TextStyle(fontSize: 22)),
            leading: Icon(Icons.home, color: Colors.blue),
            trailing: Icon(Icons.arrow_right, color: Colors.blue),
            onTap: () {},
          ),
          ListTile(
            title: Text("Météo", style: TextStyle(fontSize: 22)),
            leading: Icon(Icons.sunny, color: Colors.blue),
            trailing: Icon(Icons.arrow_right, color: Colors.blue),
            onTap: () {},
          ),
          ListTile(
            title: Text("Gallerie", style: TextStyle(fontSize: 22)),
            leading: Icon(Icons.browse_gallery, color: Colors.blue),
            trailing: Icon(Icons.arrow_right, color: Colors.blue),
            onTap: () {},
          ),
          ListTile(
            title: Text("Pays", style: TextStyle(fontSize: 22)),
            leading: Icon(Icons.place, color: Colors.blue),
            trailing: Icon(Icons.arrow_right, color: Colors.blue),
            onTap: () {},
          ),
          ListTile(
            title: Text("Contact", style: TextStyle(fontSize: 22)),
            leading: Icon(Icons.contacts, color: Colors.blue),
            trailing: Icon(Icons.arrow_right, color: Colors.blue),
            onTap: () {},
          ),
          ListTile(
            title: Text("Paramètres", style: TextStyle(fontSize: 22)),
            leading: Icon(Icons.settings, color: Colors.blue),
            trailing: Icon(Icons.arrow_right, color: Colors.blue),
            onTap: () {},
          ),
          ListTile(
            title: Text("Déconnexion", style: TextStyle(fontSize: 22)),
            leading: Icon(Icons.home, color: Colors.blue),
            trailing: Icon(Icons.arrow_right, color: Colors.blue),
            onTap: () {},
          ),
        ],
      )
    );
  }
}
