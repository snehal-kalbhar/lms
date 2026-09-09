
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'authwrapper.dart';

import 'firebase_options.dart';


void main() async {
  // Required before using Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LMSApp());
}

class LMSApp extends StatelessWidget {
  const LMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Codegurucool',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B5FEF),
        ),

        scaffoldBackgroundColor:
            const Color(0xFFF6F7FB),

        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFFF6F7FB),
          surfaceTintColor: Colors.transparent,
        ),

        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      // AuthWrapper decides where the user goes
      home: AuthWrapper(),
    );
  }
}


