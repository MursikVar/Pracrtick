class RegistrUser {
  final String login;
  final String password;
  final String user_name;

  RegistrUser({required this.login,required this.password,required this.user_name});

  Map<String, dynamic> toJson() => {
    'login' : login,
    'password' : password,
    'user_name' : user_name,
  };
}

class RegistrResponse{
  final String access_token;
  final String refresh_token;
  final String token_type;

  RegistrResponse({required this.access_token, required this.refresh_token, required this.token_type});

  factory RegistrResponse.fromJson(Map<String, dynamic> json) 
  {
    return RegistrResponse(
      access_token: json['access_token'],
      refresh_token: json['refresh_token'], 
      token_type: json['token_type'],
    );
  }
}

