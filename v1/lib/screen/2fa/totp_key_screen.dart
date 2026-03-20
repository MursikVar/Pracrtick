import 'package:flutter/material.dart';
import 'package:auth_totp/auth_totp.dart';
import 'package:test2/api/api.dart';
import 'package:test2/model/authentication/login_user.dart';
import 'package:test2/screen/user_profile/profile/profile_screen.dart';
import 'package:test2/shared/shared_token.dart';

class TotpKeyScreen extends StatefulWidget {
  final LoginResponse response;
  const TotpKeyScreen({super.key, required this.response});

  @override
  State<TotpKeyScreen> createState() => _TotpKeyScreenState();
}

class _TotpKeyScreenState extends State<TotpKeyScreen> {
  String code = "";
  String? _secret;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSecret();
  }

  Future<void> _fetchSecret() async {
    try {
      final totpKey = await Api().getTotpKey(widget.response.access_token);
      setState(() {
        _secret = totpKey.totpkey;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error $_error'))
          : Center(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        labelText: 'TOTP - код',
                      ),
                      onChanged: (value) {
                        setState(() {
                          code = value;
                        });
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_secret == null) return;
                      String cleanSecret = _secret!
                          .replaceAll(' ', '')
                          .toUpperCase();
                      String expected = AuthTOTP.generateTOTPCode(
                        secretKey: cleanSecret,
                        interval: 30,
                      );
                      String cleanCode = code.trim();
                      if (expected == cleanCode) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Congratulations, TOTP is correct"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        );
                        await SharedToken().saveToken(
                          widget.response.access_token,
                          widget.response.refresh_token,
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Opps, TOTP is incorrect"),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text("Проверить"),
                  ),
                ],
              ),
            ),
    );
  }
}
