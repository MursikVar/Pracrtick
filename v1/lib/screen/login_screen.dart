import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:test2/api/api.dart';
import 'package:test2/model/login_user.dart';
import 'package:test2/shared/shared_token.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final  _formKey = GlobalKey<FormState>();
  bool _checkPassword = true;
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Регистрация'),
        centerTitle: true,
      ),
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
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                TextFormField(
                  controller: _passwordController,
                  validator: FormBuilderValidators.password(
                    errorText: 'Проверьте ваш пароль',
                    minLength: 6,
                    maxLength: 10,
                    checkNullOrEmpty: true,
                    minLowercaseCount: 1,
                    minUppercaseCount: 1,
                    minNumberCount: 1
                  ),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    suffixIcon: IconButton(onPressed: (){
                      setState(() {
                        _checkPassword = !_checkPassword;
                      });
                    }, 
                    icon: Icon(_checkPassword ? Icons.visibility : Icons.visibility_off)
                    )
                  ),
                  obscureText: _checkPassword,
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                  onPressed: () async{
                    if(_formKey.currentState!.validate())
                    {
                      final loginUser =LoginUser(
                        login: _loginController.text.trim(),
                        password: _passwordController.text.trim()
                      );

                      LoginResponse response =  await Api().loginUser(loginUser);
                      await SharedToken().saveToken(response.access_token, response.refresh_token);
                      Navigator.pushReplacementNamed(context, '/qrcode');
                    }
                  }, 
                  child: Text('Войти'),
                ),
                SizedBox(height: 100,), 
                ElevatedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/registor'), child: Text('Зарегистрироваться'))

              ],
            )
          ),
        ),
      ),
    );
  }
}