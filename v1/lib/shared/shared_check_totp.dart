import 'package:shared_preferences/shared_preferences.dart';

class SharedCheckTotp {
  static const String _totpKey = 'totp_key';

  Future<void> initDefault() async{
    final shared = SharedPreferencesAsync();
    if(!(await shared.containsKey(_totpKey))){
      await shared.setBool(_totpKey, false);
    }
  }

  Future<void> saveBoolTotp(bool value) async {
    final shared = SharedPreferencesAsync();
    await shared.setBool(_totpKey, value);
  }

  Future<bool?> getBoolTotp() async {
    final shared = SharedPreferencesAsync();
    return shared.getBool(_totpKey);
  }

}
