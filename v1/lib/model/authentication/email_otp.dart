class EmailOtp {
  final String login;
  final String code;

  EmailOtp({required this.login, required this.code});

  Map<String, dynamic> toJson() => {'login' : login, 'code' : code};
}