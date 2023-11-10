import 'package:flutter/material.dart';
import 'package:login_app/presentation/Screens/home_screen/home_screen.dart';
import 'package:login_app/presentation/Screens/login_screens/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomescreenView(),
    );
  }
}