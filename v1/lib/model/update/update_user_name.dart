class UpdateUserName {
  final String new_username;

  UpdateUserName({required this.new_username});

  Map<String, dynamic> toJson() => {'new_username' : new_username};
}

class ResponceUpdateUserName{
  final String user_name;

  ResponceUpdateUserName({required this.user_name});

  factory ResponceUpdateUserName.fromJson(Map<String, dynamic> json){
    return ResponceUpdateUserName(user_name: json['user_name']);
  }
}