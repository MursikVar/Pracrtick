import 'package:flutter/material.dart';
import 'package:auth_totp/auth_totp.dart';
import 'package:test2/screen/profile_screen.dart';

class VerificationPage extends StatefulWidget {
  final String secret;
  const VerificationPage({super.key, required this.secret});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  String code = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
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
              onPressed: () {
                String cleanSecret = widget.secret
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
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
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
                        borderRadius: BorderRadius.all(Radius.circular(10)),
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
