import 'package:flutter/material.dart';
import 'package:auth_totp/auth_totp.dart';
import 'package:test2/screen/2fa/verification_page.dart';
import 'package:flutter/services.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  String secret = AuthTOTP.createSecret(
    length: 16,
    autoPadding: true,
    secretKeyStyle: SecretKeyStyle.upperLowerCase,
  );
  String appName = "TOTP";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TOTP - код", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Center(
            child: Text(
              "Для продолжения отсканируйте QR code или скопируйте секретный код и вставте в установленном приложении для 2fa.",
            ),
          ),
          Image.network(
            AuthTOTP.getQRCodeUrl(appName: appName, secretKey: secret),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: TextEditingController(text: secret),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: secret));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Секретный ключ скопирован успешно'),
                      ),
                    );
                  },
                  icon: Icon(Icons.copy),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
              obscureText: true,
              readOnly: true,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerificationPage(secret: secret),
                ),
              );
            },
            child: const Text("Ввести код"),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            secret = AuthTOTP.createSecret(
              length: 16,
              autoPadding: true,
              secretKeyStyle: SecretKeyStyle.upperLowerCase,
            );
            ;
            print(AuthTOTP.generateTOTPCode(secretKey: secret, interval: 30));
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
