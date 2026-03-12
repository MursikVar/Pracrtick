import 'package:flutter/material.dart';
import 'package:test2/api/api.dart';
import 'package:test2/model/profile/user_profile.dart';
import 'package:test2/model/update/update_login.dart';
import 'package:test2/model/update/update_password.dart';
import 'package:test2/model/update/update_user_name.dart';
import 'package:test2/screen/user_profile/home/user_home.dart';
import 'package:test2/screen/user_profile/message/massage.dart';
import 'package:test2/shared/shared_token.dart';
import 'package:test2/widget/profile_card_widget.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;
  String? _error;
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final token = await SharedToken().getToken();
      if (token == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Пользователь не найден')));
        return;
      }
      final profile = await Api().getUserProfile(token);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     onPressed: () async {
      //       await SharedToken().deliteToken();
      //       if (mounted) {
      //         Navigator.pushReplacementNamed(context, '/login');
      //       }
      //     },
      //     icon: Icon(Icons.access_alarm_rounded),
      //   ),
      // ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        backgroundColor: Colors.blue[300],
        indicatorColor: Colors.deepPurple[100],
        selectedIndex: currentPageIndex,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: ''),
          NavigationDestination(
            icon: Icon(Icons.account_box_rounded),
            label: '',
          ),
          NavigationDestination(icon: Icon(Icons.message_rounded), label: ''),
        ],
      ),
      body: _build(),
    );
  }

  Widget _build() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка $_error'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async{
                Navigator.pushReplacementNamed(context, '/');
                await SharedToken().deliteToken();
              },
              child: Text('Авторизоваться'),
            ),
          ],
        ),
      );
    }

    return [homeScreen(), _userAccount(), messenger()][currentPageIndex];
  }

  Padding _userAccount() {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle, size: 200),
                SizedBox(height: 30),
                profileCardWidget(_profile!.login, 'Логин', _updateLogin),
                profileCardWidget(
                  _profile!.user_name,
                  'Имя пользователя',
                  _updateUserName,
                ),
                profileCardWidget('**************', 'Пароль', _updatePassword),
              ],
            ),
          ),
          Positioned(
            top: 20,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                await SharedToken().deliteToken();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _updateUserName() {
    final _newUserName = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Изменить имя пользователя'),
          content: TextField(
            controller: _newUserName,
            decoration: InputDecoration(hintText: 'Введите новое имя'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newUserName = UpdateUserName(
                  new_username: _newUserName.text.trim(),
                );
                final token = await SharedToken().getToken();
                if (token != null) {
                  await Api().updateUserName(token, newUserName);
                  Navigator.pop(context);
                  final profile = await Api().getUserProfile(token);
                  if (mounted) {
                    setState(() {
                      _profile = profile;
                      _isLoading = false;
                    });
                  }
                }
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _updateLogin() {
    final _newLogin = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Изменить Email'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _newLogin,
              decoration: InputDecoration(hintText: 'Введите новый Email'),
              autofocus: true,
              validator: FormBuilderValidators.email(
                checkNullOrEmpty: true,
                errorText: 'Проверьте ваш email',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newLogin = UpdateLogin(
                    new_login: _newLogin.text.trim(),
                  );
                  final token = await SharedToken().getToken();
                  if (token != null) {
                    ResponseUpdateLogin response = await Api().updateLogin(
                      token,
                      newLogin,
                    );
                    await SharedToken().deliteToken();
                    await SharedToken().saveToken(
                      response.access_token,
                      response.refresh_token,
                    );
                    final newToken = await SharedToken().getToken();
                    Navigator.pop(context);
                    final profile = await Api().getUserProfile(newToken);
                    if (mounted) {
                      setState(() {
                        _profile = profile;
                        _isLoading = false;
                      });
                    }
                  }
                }
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _updatePassword() {
    final _newPassword = TextEditingController();
    final _newRepiatPassword = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    bool _checkPassword = true;
    bool _checkRepeatPassword = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Изменить пароль'),
          content: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _newPassword,
                  obscureText: _checkPassword,
                  validator: FormBuilderValidators.password(
                    errorText: 'Проверьте ваш пароль',
                    minLength: 6,
                    maxLength: 10,
                    checkNullOrEmpty: true,
                    minLowercaseCount: 1,
                    minUppercaseCount: 1,
                    minNumberCount: 1,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Repeat Password',
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
                  autofocus: true,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _newRepiatPassword,
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
                  validator: FormBuilderValidators.password(
                    errorText: 'Проверьте ваш пароль',
                    minLength: 6,
                    maxLength: 10,
                    checkNullOrEmpty: true,
                    minLowercaseCount: 1,
                    minUppercaseCount: 1,
                    minNumberCount: 1,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newPassword = UpdatePassword(
                    new_password: _newPassword.text.trim(),
                  );
                  final token = await SharedToken().getToken();
                  if (_newPassword.text != _newRepiatPassword.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('пароли не совпадают')),
                    );
                    return;
                  }
                  if (token != null) {
                    await Api().updatePassword(token, newPassword);
                  }
                  Navigator.pop(context);
                  // final profile = await Api().getUserProfile(token);
                  // if (mounted) {
                  //   setState(() {
                  //     _profile = profile;
                  //     _isLoading = false;
                  //   });
                  // }
                }
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}
