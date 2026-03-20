import 'package:flutter/material.dart';
import 'package:test2/api/api.dart';
import 'package:test2/model/authentication/email_otp.dart';
import 'package:test2/model/authentication/registr_user.dart';
import 'package:test2/shared/shared_token.dart';

class EmailOtpScreen extends StatefulWidget {
  const EmailOtpScreen({super.key});

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final EmailOtp emailOtp = arguments['emailOtp'] as EmailOtp;
    final RegistrUser user = arguments['user'] as RegistrUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
          icon: Icon(Icons.exit_to_app),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'на вашу почту ${emailOtp.login} был отправлен код, для подтверждения почты введите его',
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'OTP - код',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                autofocus: true,
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async{
                    if (emailOtp.code == _codeController.text.trim()) {
                      RegistrResponse response = await Api().registrUser(user);
                      await SharedToken().saveToken(response.access_token, response.refresh_token);
                      Navigator.pushReplacementNamed(context, '/profile');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('пароли не совпадают')),
                      );
                    }
                  },
                  child: Text('Подтвердить код'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
