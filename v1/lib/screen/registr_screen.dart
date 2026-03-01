import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:test2/api/api.dart';
import 'package:test2/model/registr_user.dart';
import 'package:test2/shared/shared_token.dart';

class RegistrScreen extends StatefulWidget {
  const RegistrScreen({super.key});

  @override
  State<RegistrScreen> createState() => _RegistrScreenState();
}

class _RegistrScreenState extends State<RegistrScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _checkPassword = true;
  bool _checkRepeatPassword = true;

  final _loginController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  @override
  void dispose() {
    _loginController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Регистрация :)'), centerTitle: true),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _loginController,
                  validator: FormBuilderValidators.email(
                    checkNullOrEmpty: true,
                    errorText: 'Проверьте ваш email',
                  ),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _userNameController,
                  validator: FormBuilderValidators.username(
                    allowDash: false,
                    allowDots: false,
                    allowNumbers: false,
                    allowSpace: true,
                    allowSpecialChar: false,
                    allowUnderscore: true,
                    checkNullOrEmpty: true,
                    errorText: 'Проверьте имя пользователя',
                  ),
                  decoration: InputDecoration(
                    labelText: 'User Name',
                    prefixIcon: Icon(Icons.account_circle_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  validator: FormBuilderValidators.password(
                    errorText: 'Проверьте ваш пароль',
                    minLength: 6,
                    maxLength: 10,
                    checkNullOrEmpty: true,
                    minLowercaseCount: 1,
                    minUppercaseCount: 1,
                    minNumberCount: 1,
                  ),
                  obscureText: _checkPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _checkPassword = !_checkPassword;
                        });
                      },
                      icon: Icon(
                        _checkPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _repeatPasswordController,
                  obscureText: _checkRepeatPassword,
                  decoration: InputDecoration(
                    labelText: 'Repeat Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _checkRepeatPassword = !_checkRepeatPassword;
                        });
                      },
                      icon: Icon(
                        _checkRepeatPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final user = RegistrUser(
                        login: _loginController.text.trim(),
                        password: _passwordController.text.trim(),
                        user_name: _userNameController.text.trim(),
                      );
                      if (_passwordController.text !=
                          _repeatPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('пароли не совпадают')),
                        );
                        return;
                      }
                      RegistrResponse response = await Api().registrUser(user);
                      await SharedToken().saveToken(
                        response.access_token,
                        response.refresh_token,
                      );
                      Navigator.pushReplacementNamed(context, '/profile');
                    }
                  },
                  child: Text('Заргистрироваться'),
                ),
                SizedBox(height: 100),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: Text('Войти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
