class LoginUser {
  final String login;
  final String password;

  LoginUser({required this.login, required this.password});

  Map<String, dynamic> toJson() => {'login': login, 'password': password};
}

class LoginResponse{
  final String access_token;
  final String refresh_token;
  final String token_type;

  LoginResponse({required this.access_token, required this.refresh_token, required this.token_type});

  factory LoginResponse.fromJson(Map<String, dynamic> json){
    return LoginResponse(
      access_token: json['access_token'], 
      refresh_token: json['refresh_token'], 
      token_type: json['token_type']
    );
  }
}
