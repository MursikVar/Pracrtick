class UserProfile {
  final String login;
  final String user_name;

  UserProfile({required this.login, required this.user_name});

  factory UserProfile.fromJson(Map<String, dynamic> json){
    return UserProfile(
      login: json['login'],
     user_name: json['user_name']
    );
  }
}