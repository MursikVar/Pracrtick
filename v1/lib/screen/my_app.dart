import 'package:flutter/material.dart';
import 'package:test2/screen/login_screen.dart';
import 'package:test2/screen/profile_screen.dart';
import 'package:test2/screen/registr_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login' : (context) => LoginScreen(),
        '/registor' : (context) => RegistrScreen(),
        '/profile' : (context) => ProfileScreen()
      }, 
    );
  }
}