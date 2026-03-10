import 'package:flutter/material.dart';
import 'package:test2/shared/shared_token.dart';

class NullScreen extends StatefulWidget {
  const NullScreen({super.key});

  @override
  State<NullScreen> createState() => _NullScreenState();
}

class _NullScreenState extends State<NullScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async{
    final token = await  SharedToken().getToken();

    if(mounted){
      if(token != null){
        Navigator.pushReplacementNamed(context, '/profile');
      }
      else{
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        ),
      ),
    );
  }
}
