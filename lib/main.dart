import 'package:fase_1/Screens/home_screen.dart';
import 'package:fase_1/Screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fast Note',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xfffBD3924)
      ),
      home: LoginScreen(),
      //home: SplashScreen(),
    );
  }
}