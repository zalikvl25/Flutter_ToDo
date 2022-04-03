import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_flutter_todo/pages/home.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.teal,
          backgroundColor: Colors.white60,
          appBarTheme: const AppBarTheme(
            color: Colors.teal,
          ),
        ),
        home: const Home(),
      ));
}