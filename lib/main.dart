import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/todo_provider.dart';
import 'providers/settings_provider.dart';
import 'todo_web_simple.dart';


import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb && Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
  }

  tz.initializeTimeZones();
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Farsy',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('id', 'ID'),
            ],
            locale: const Locale('id', 'ID'),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF4F6F8), // Soft Blue Grey
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                primary: Colors.indigo,
                secondary: Colors.deepOrangeAccent, // Coral/Vibrant Orange
                tertiary: Colors.teal, // Fresh Accents
                surface: Colors.white,
                background: const Color(0xFFF4F6F8),
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.indigo,
                elevation: 0,
                centerTitle: true,
              ),
              cardTheme: CardThemeData(
                elevation: 8,
                shadowColor: Colors.indigo.withOpacity(0.15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: Colors.indigo.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              textTheme: GoogleFonts.outfitTextTheme(
                Theme.of(context).textTheme,
              ).apply(
                bodyColor: const Color(0xFF2C3E50), // Dark Blue Grey text
                displayColor: Colors.indigo,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF121212),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                primary: const Color(0xFF5C6BC0), // Lighter Indigo
                secondary: Colors.deepOrangeAccent,
                tertiary: Colors.tealAccent,
                surface: const Color(0xFF1E1E1E),
                background: const Color(0xFF121212),
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
              ),
              cardTheme: CardThemeData(
                elevation: 4,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C6BC0),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              textTheme: GoogleFonts.outfitTextTheme(
                Theme.of(context).textTheme,
              ).apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
            ),
            home: const TodoWebSimple(),
          );
        },
      ),
    );
  }
}
