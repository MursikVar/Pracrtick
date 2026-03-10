class UpdateLogin {
  final String new_login;

  UpdateLogin({required this.new_login});

  Map<String, dynamic> toJson() => {'new_login': new_login};
}

class ResponseUpdateLogin {
  final String access_token;
  final String refresh_token;
  final String token_type;
  final String login;

  ResponseUpdateLogin({
    required this.access_token,
    required this.login,
    required this.refresh_token,
    required this.token_type,
  });

  factory ResponseUpdateLogin.fromJson(Map<String, dynamic> json) {
    return ResponseUpdateLogin(
      access_token: json['access_token'],
      login: json['login'],
      refresh_token: json['refresh_token'],
      token_type: json['token_type'],
    );
  }
}
