import 'package:flutter/material.dart';
import 'package:test2/screen/2fa/email_otp_screen.dart';
import 'package:test2/screen/2fa/qr_screen.dart';
// import 'package:test2/screen/2fa/verification_page.dart';
import 'package:test2/screen/login_registration/authentication_screen.dart';
import 'package:test2/screen/null_screen.dart';
import 'package:test2/screen/user_profile/profile/profile_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/' : (context) => NullScreen(),
        '/login' : (context) => AuthenticationScreen(),
        '/emailOtp' : (context) => EmailOtpScreen(),
        '/profile' : (context) => ProfileScreen(),
        '/qrcode' : (context) => QrScreen(),
        // '/verification' : (context) => VerificationPage()
      }, 
    );
  }
}