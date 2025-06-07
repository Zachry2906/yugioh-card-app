import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

// Import screens dan providers
import 'screens/home_screen.dart';
import 'providers/card_provider.dart';
import 'providers/deck_provider.dart';
import 'providers/favorites_provider.dart';
import 'services/database_helper.dart';

// Import sqflite dengan conditional import
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory for different platforms
  if (!kIsWeb) {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // For desktop platforms, we'll use regular sqflite
        // sqflite_common_ffi is not needed in this case
      }
    } catch (e) {
      print('Platform detection error: $e');
    }
  }

  // Initialize database
  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    print('Database initialization error: $e');
    // Continue without database if initialization fails
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CardProvider()),
        ChangeNotifierProvider(create: (_) => DeckProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Yu-Gi-Oh! TCG',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.purple[800],
            foregroundColor: Colors.white,
          ),
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
