import 'package:flutter/material.dart';
import 'package:test2/screen/login_registration/login_screen.dart';
import 'package:test2/screen/login_registration/registr_screen.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title:  Text('TabBar Sample'),
          bottom:  TabBar(
            tabs: <Widget>[
              Tab(text: 'Войти',),
              Tab(text: 'Зарегистироваться',),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            LoginScreen(),
            RegistrScreen(),
          ],
        ),
      ),
    );
  }
}