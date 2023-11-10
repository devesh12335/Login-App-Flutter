import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login_app/presentation/Screens/home_screen/home_screen.dart';
import 'package:login_app/presentation/Screens/login_screens/login_screen.dart';

import 'app.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}


