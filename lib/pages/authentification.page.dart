import "package:flutter/material.dart";
import "../widgets/base_page.dart";
import "../theme/app_theme.dart";
import "../services/auth_service.dart";
import "../services/snackbar_service.dart";

class AuthentificiationPage extends StatelessWidget {
  final TextEditingController txt_login;
  final TextEditingController txt_password;
  final AuthService _authService = AuthService();

  AuthentificiationPage({super.key})
    : txt_login = TextEditingController(),
      txt_password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Authentification",
      showDrawer: false,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            Container(
              padding: AppTheme.paddingMedium,
              child: TextFormField(
                decoration: AppTheme.inputDecoration(
                  "Email",
                  "Entrez votre email",
                  Icons.email,
                ),
                controller: txt_login,
              ),
            ),
            Container(
              padding: AppTheme.paddingMedium,
              child: TextFormField(
                decoration: AppTheme.inputDecoration(
                  "Mot de passe",
                  "Entrez votre mot de passe",
                  Icons.lock,
                ),
                controller: txt_password,
                obscureText: true,
              ),
            ),
            Padding(
              padding: AppTheme.paddingMedium,
              child: ElevatedButton(
                onPressed: () {
                  _onAuthentifier(context); // _ car private
                },
                child: const Text("Authentifier"),
              ),
            ),
            Padding(
              padding: AppTheme.paddingMedium,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/inscription');
                },
                child: Text("Inscription", style: AppTheme.linkTextStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAuthentifier(BuildContext context) async {
    // Capturer le contexte avant l'opération asynchrone
    final navigator = Navigator.of(context);

    // Tenter la connexion avec Firebase
    // La validation est maintenant gérée par le service d'authentification
    final userCredential = await _authService.signIn(
      email: txt_login.text.trim(),
      password: txt_password.text,
      context: context,
    );

    // Si la connexion a réussi, rediriger vers la page d'accueil
    if (userCredential != null && context.mounted) {
      navigator.pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }
}
