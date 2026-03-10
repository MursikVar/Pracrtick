import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:test2/model/google.dart';
import 'package:test2/model/update/update_login.dart';
import 'package:test2/model/update/update_password.dart';
import 'package:test2/model/update/update_user_name.dart';

import '../constant/api_path.dart';
import '../constant/constant.dart';
import 'package:http/http.dart' as http;

import '../model/authentication/login_user.dart';
import '../model/authentication/registr_user.dart';
import '../model/profile/user_profile.dart';

class Api {
  Future<RegistrResponse> registrUser(RegistrUser user) async {
    final url = Uri.parse(
      '${Constant.SERVER_PATH}${ApiPath.API_MAIN}${ApiPath.API_AUTHENTICATION}/register',
    );
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(
          '${responseData['access_token']}\n${responseData['refresh_token']}\n${responseData['token_type']}',
        );
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
      '${Constant.SERVER_PATH}${ApiPath.API_MAIN}${ApiPath.API_USER}/me',
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $access_token',
        },
      );

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
      '${Constant.SERVER_PATH}${ApiPath.API_MAIN}${ApiPath.API_AUTHENTICATION}/login',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(loginUser.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return LoginResponse.fromJson(responseData);
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error $e');
    }
  }

  Future<GoogleResponse> googleIn() async {
    final url = Uri.parse(
      '${Constant.SERVER_PATH}${ApiPath.API_MAIN}${ApiPath.API_AUTHENTICATION}${ApiPath.GOOGLE_API}',
    );

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': googleAuth.idToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return GoogleResponse.fromJson(responseData);
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка входа $e');
    }
  }

  Future<ResponceUpdateUserName> updateUserName(
    String accessToken,
    UpdateUserName newUserName,
  ) async {
    final url = Uri.parse(
      '${Constant.SERVER_PATH}${ApiPath.API_MAIN}${ApiPath.API_UPDATE}/username',
    );

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(newUserName.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return ResponceUpdateUserName.fromJson(responseData);
      } else {
        throw Exception('${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ResponseUpdateLogin> updateLogin(
    String accessToken,
    UpdateLogin newLogin,
  ) async {
    final url = Uri.parse(
      '${Constant.SERVER_PATH}${ApiPath.API_MAIN}${ApiPath.API_UPDATE}/login',
    );
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(newLogin.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return ResponseUpdateLogin.fromJson(responseBody);
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error $e');
    }
  }

  Future<void> updatePassword(
    String accessToken,
    UpdatePassword newPassword,
  ) async {
    final url = Uri.parse(
      '${Constant.SERVER_PATH}${ApiPath.API_MAIN}${ApiPath.API_UPDATE}/password',
    );
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(newPassword.toJson()),
      );
      if(response.statusCode!=200){
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error $e');
    }
  }
}
