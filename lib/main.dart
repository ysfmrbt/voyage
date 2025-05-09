import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voyage/pages/authentification.page.dart';
import 'package:voyage/pages/inscription.page.dart';
import 'package:voyage/pages/home.page.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/gallery_provider.dart';
import 'providers/country_provider.dart';
import 'package:voyage/pages/contact.page.dart';
import 'package:voyage/pages/gallerie.page.dart';
import 'package:voyage/pages/parametres.page.dart';
import 'pages/settings.page.dart';
import 'package:voyage/pages/pays.page.dart';
import 'package:voyage/pages/mates.page.dart';
import 'package:voyage/pages/meteo.page.dart';
import 'pages/gallery_search.page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('Initialisation de Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialisé avec succès!');
    print(
      'Projet Firebase: ${DefaultFirebaseOptions.currentPlatform.projectId}',
    );
    print('API Key: ${DefaultFirebaseOptions.currentPlatform.apiKey}');

    // Vérifier si l'authentification est initialisée
    final auth = FirebaseAuth.instance;
    print('Auth instance: ${auth.app.name}');
    print('Utilisateur actuel: ${auth.currentUser?.uid ?? "Non connecté"}');
  } catch (e) {
    print('ERREUR lors de l\'initialisation de Firebase: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ChangeNotifierProvider(create: (_) => CountryProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final routes = {
    '/home': (context) => Home(),
    '/inscription': (context) => InscriptionPage(),
    '/authentification': (context) => AuthentificiationPage(),
    '/contact': (context) => ContactPage(),
    '/gallerie': (context) => GalleriePage(),
    '/parametres': (context) => ParametresPage(),
    '/settings': (context) => const SettingsPage(),
    '/pays': (context) => PaysPage(),
    '/mates': (context) => MatesPage(),
    '/meteo': (context) => const MeteoPage(),
    '/gallery_search': (context) => const GallerySearchPage(),
  };
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Update the AppTheme with the current theme mode
    AppTheme.setThemeMode(themeProvider.isDarkMode);

    return MaterialApp(
      routes: routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: AppTheme.fontFamily,
        primaryColor: AppTheme.primaryColor,
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        colorScheme:
            themeProvider.isDarkMode
                ? ColorScheme.dark(
                  primary: AppTheme.primaryColor,
                  secondary: AppTheme.secondaryColor,
                  error: AppTheme.errorColor,
                  surface: AppTheme.surfaceColor,
                  onPrimary: AppTheme.lightTextColor,
                  onSecondary: AppTheme.lightTextColor,
                  onSurface: AppTheme.textColor,
                  // Use surface instead of deprecated background
                )
                : ColorScheme.light(
                  primary: AppTheme.primaryColor,
                  secondary: AppTheme.secondaryColor,
                  error: AppTheme.errorColor,
                  surface: AppTheme.surfaceColor,
                  onPrimary: AppTheme.lightTextColor,
                  onSecondary: AppTheme.lightTextColor,
                  onSurface: AppTheme.textColor,
                  // Use surface instead of deprecated background
                ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          titleTextStyle: AppTheme.appBarTitleStyle,
          iconTheme: IconThemeData(color: AppTheme.lightTextColor),
        ),
        textTheme: TextTheme(
          titleLarge: AppTheme.headingStyle,
          titleMedium: AppTheme.subheadingStyle,
          bodyLarge: AppTheme.bodyTextStyle,
          bodyMedium: AppTheme.bodyTextStyle,
          labelLarge: AppTheme.buttonTextStyle,
          labelMedium: AppTheme.captionStyle,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppTheme.primaryButtonStyle,
        ),
        textButtonTheme: TextButtonThemeData(style: AppTheme.textButtonStyle),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(width: 1.5, color: AppTheme.secondaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              width: 1.5,
              color:
                  themeProvider.isDarkMode
                      ? AppTheme.dividerColor
                      : Colors.grey[400]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(width: 2, color: AppTheme.primaryColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(width: 1.5, color: AppTheme.errorColor),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          filled: true,
          fillColor:
              themeProvider.isDarkMode ? AppTheme.surfaceColor : Colors.white,
          labelStyle: TextStyle(
            color:
                themeProvider.isDarkMode
                    ? Colors.white
                    : AppTheme.secondaryColor,
            fontWeight: AppTheme.mediumWeight,
          ),
          hintStyle: TextStyle(
            color:
                themeProvider.isDarkMode ? Color(0xFFAAAAAA) : Colors.grey[600],
          ),
        ),
        cardTheme: AppTheme.cardTheme,
        listTileTheme: AppTheme.listTileTheme,
        // Brightness is determined by the ColorScheme
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            return Home();
          }
          return InscriptionPage();
        },
      ),
    );
  }
}
