import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'snackbar_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // État actuel de l'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Validation de l'email
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'L\'email est requis';
    }

    // Expression régulière pour valider l'email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Veuillez entrer une adresse email valide';
    }

    return null;
  }

  // Validation du mot de passe
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }

    // Vérifier si le mot de passe contient au moins un chiffre
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }

    return null;
  }

  // Inscription avec email et mot de passe
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // Valider l'email et le mot de passe
    final emailError = validateEmail(email);
    if (emailError != null) {
      SnackbarService.showError(context, emailError);
      return null;
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      SnackbarService.showError(context, passwordError);
      return null;
    }

    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fermer l'indicateur de chargement et afficher le message de succès
      if (context.mounted) {
        Navigator.of(context).pop();

        // Vérifier si l'utilisateur a été créé
        if (userCredential.user != null) {
          SnackbarService.showSuccess(context, 'Inscription réussie!');
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        // Fermer l'indicateur de chargement
        Navigator.of(context).pop();

        String message;
        switch (e.code) {
          case 'weak-password':
            message = 'Le mot de passe est trop faible.';
            break;
          case 'email-already-in-use':
            message = 'Un compte existe déjà avec cet email.';
            break;
          case 'invalid-email':
            message = 'L\'adresse email n\'est pas valide.';
            break;
          case 'operation-not-allowed':
            message =
                'L\'inscription par email/mot de passe n\'est pas activée.';
            break;
          case 'network-request-failed':
            message =
                'Problème de connexion réseau. Vérifiez votre connexion Internet.';
            break;
          default:
            message = 'Une erreur s\'est produite: ${e.message}';
        }
        SnackbarService.showError(context, message);
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        // Fermer l'indicateur de chargement
        Navigator.of(context).pop();

        SnackbarService.showError(context, 'Une erreur s\'est produite: $e');
      }
      return null;
    }
  }

  // Connexion avec email et mot de passe
  Future<UserCredential?> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // Valider l'email et le mot de passe
    final emailError = validateEmail(email);
    if (emailError != null) {
      SnackbarService.showError(context, emailError);
      return null;
    }

    if (password.isEmpty) {
      SnackbarService.showError(context, 'Le mot de passe est requis');
      return null;
    }

    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fermer l'indicateur de chargement
      if (context.mounted) {
        Navigator.of(context).pop();

        // Vérifier si l'utilisateur est connecté
        if (userCredential.user != null) {
          SnackbarService.showSuccess(context, 'Connexion réussie!');
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Capturer le contexte actuel
      if (context.mounted) {
        // Fermer l'indicateur de chargement
        Navigator.of(context).pop();

        String message;
        switch (e.code) {
          case 'user-not-found':
            message = 'Aucun utilisateur trouvé avec cet email.';
            break;
          case 'wrong-password':
            message = 'Mot de passe incorrect.';
            break;
          case 'invalid-email':
            message = 'L\'adresse email n\'est pas valide.';
            break;
          case 'user-disabled':
            message = 'Ce compte a été désactivé.';
            break;
          case 'network-request-failed':
            message =
                'Problème de connexion réseau. Vérifiez votre connexion Internet.';
            break;
          case 'too-many-requests':
            message =
                'Trop de tentatives de connexion. Veuillez réessayer plus tard.';
            break;
          default:
            message = 'Une erreur s\'est produite: ${e.message}';
        }

        SnackbarService.showError(context, message);
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        // Fermer l'indicateur de chargement
        Navigator.of(context).pop();

        SnackbarService.showError(context, 'Une erreur s\'est produite: $e');
      }
      return null;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    // Valider l'email
    final emailError = validateEmail(email);
    if (emailError != null) {
      SnackbarService.showError(context, emailError);
      return;
    }

    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _auth.sendPasswordResetEmail(email: email);

      // Fermer l'indicateur de chargement
      if (context.mounted) {
        Navigator.of(context).pop();

        SnackbarService.showSuccess(
          context,
          'Un email de réinitialisation a été envoyé à $email',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        // Fermer l'indicateur de chargement
        Navigator.of(context).pop();

        String message;
        switch (e.code) {
          case 'invalid-email':
            message = 'L\'adresse email n\'est pas valide.';
            break;
          case 'user-not-found':
            message = 'Aucun utilisateur trouvé avec cet email.';
            break;
          case 'network-request-failed':
            message =
                'Problème de connexion réseau. Vérifiez votre connexion Internet.';
            break;
          case 'too-many-requests':
            message = 'Trop de tentatives. Veuillez réessayer plus tard.';
            break;
          default:
            message = 'Une erreur s\'est produite: ${e.message}';
        }
        SnackbarService.showError(context, message);
      }
    } catch (e) {
      if (context.mounted) {
        // Fermer l'indicateur de chargement
        Navigator.of(context).pop();

        SnackbarService.showError(context, 'Une erreur s\'est produite: $e');
      }
    }
  }
}
