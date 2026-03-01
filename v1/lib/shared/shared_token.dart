import 'package:shared_preferences/shared_preferences.dart';

class SharedToken {
  Future<void> saveToken(String access_token, String refresh_token) async{
    final shared = SharedPreferencesAsync();
    await shared.setString('access_token', access_token);
    await shared.setString('refresh_token', refresh_token);
  }


  Future<void> deliteToken() async{
    final shared = SharedPreferencesAsync();
    await shared.remove('access_token');
    await shared.remove('refresh_token');
  }

  Future<String?> getToken() async{
    final shared = SharedPreferencesAsync();
    return shared.getString('access_token');
  }
}