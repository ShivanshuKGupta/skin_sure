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
      title: 'Skin Cure',
      theme: ThemeData(
        textTheme: GoogleFonts.quicksandTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}