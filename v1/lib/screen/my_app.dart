import 'package:flutter/material.dart';
import 'package:test2/screen/2fa/qr_screen.dart';
import 'package:test2/screen/login_registration/authentication_screen.dart';
import 'package:test2/screen/null_screen.dart';
import 'package:test2/screen/user_profile/profile_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/' : (context) => NullScreen(),
        '/login' : (context) => AuthenticationScreen(),
        // '/registor' : (context) => RegistrScreen(),
        '/profile' : (context) => ProfileScreen(),
        '/qrcode' : (context) => QrScreen()
      }, 
    );
  }
}