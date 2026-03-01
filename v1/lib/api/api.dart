import 'dart:convert';

import '../constant/api_path.dart';
import '../constant/constant.dart';
import 'package:http/http.dart' as http;

import '../model/login_user.dart';
import '../model/registr_user.dart';
import '../model/user_profile.dart';

class Api {
  Future<RegistrResponse> registrUser(RegistrUser user) async {
    final url = Uri.parse(
        '${Constant.SERVER_PATH}${ApiPath.API_MAIN}${ApiPath.API_AUTHENTICATION}/register');
    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode(user.toJson()));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(
            '${responseData['access_token']}\n${responseData['refresh_token']}\n${responseData['token_type']}');
        return RegistrResponse.fromJson(responseData);
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception('Error');
    }
  }

  Future<UserProfile> getUserProfile(String? access_token) async {
    final url = Uri.parse(
        '${Constant.SERVER_PATH}${ApiPath.API_MAIN}${ApiPath.API_USER}/me');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $access_token',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return UserProfile.fromJson(responseData);
      } else {
        throw Exception(' Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error $e');
    }
  }

  Future<LoginResponse> loginUser(LoginUser loginUser) async {
    final url = Uri.parse(
        '${Constant.SERVER_PATH}${ApiPath.API_MAIN}${ApiPath.API_AUTHENTICATION}/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type' : 'application/json',
          'Accept' : 'application/json'
        },
        body: jsonEncode(loginUser.toJson())
      );
      if(response.statusCode == 200){
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return LoginResponse.fromJson(responseData);
      }
      else{
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error $e');
    }
  }
}
