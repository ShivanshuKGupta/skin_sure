import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'globals.dart';
import 'screens/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Skin Sure',
      theme: ThemeData(
        textTheme: GoogleFonts.quicksandTextTheme().copyWith(
          bodyMedium: GoogleFonts.quicksandTextTheme().bodyMedium!.copyWith(
                color: Colors.white,
              ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.quicksandTextTheme().copyWith(
          bodyMedium: GoogleFonts.quicksandTextTheme().bodyMedium!.copyWith(
                color: Colors.white,
              ),
          bodySmall: GoogleFonts.quicksandTextTheme().bodySmall!.copyWith(
                color: Colors.white,
              ),
          bodyLarge: GoogleFonts.quicksandTextTheme().bodyLarge!.copyWith(
                color: Colors.white,
              ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}
