import 'package:flutter/material.dart';
import 'package:test2/api/api.dart';
import 'package:test2/model/user_profile.dart';
import 'package:test2/shared/shared_token.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;
  String? _error;

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
      appBar: AppBar(
        title: Text(_profile?.login ?? ''),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () async {
            await SharedToken().deliteToken();
            if(mounted)
            {
              Navigator.pushReplacementNamed(context, '/login');
            }
          }, icon: Icon(Icons.exit_to_app))
        ],
      ), 
      body: _build()
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
            ElevatedButton(onPressed: _loadProfile, child: Text('Повторить')),
          ],
        ),
      );
    }

    return Center(
      child: Text(_profile!.user_name)
    );
  }
}


