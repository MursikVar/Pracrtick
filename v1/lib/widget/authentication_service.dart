import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test2/api/api.dart';
import 'package:test2/model/google.dart';
import 'package:test2/shared/shared_token.dart';


class AuthButtons extends StatelessWidget {
  const AuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () async {
              try {
                GoogleResponse response = await Api().googleIn();
                if (response != null) {
                  await SharedToken().saveToken(
                    response.access_token,
                    response.refresh_token,
                  );
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/profile');
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Ошибка входа: $e')));
                }
              }
            },
            icon: Icon(FontAwesomeIcons.google),
          ),
          IconButton(onPressed: () {}, icon: Icon(FontAwesomeIcons.yandex)),
          IconButton(onPressed: () {}, icon: Icon(FontAwesomeIcons.vk)),
          IconButton(
            onPressed: () {},
            icon: Icon(FontAwesomeIcons.odnoklassniki),
          ),
        ],
      ),
    );
  }
}
