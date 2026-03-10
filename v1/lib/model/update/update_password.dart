class UpdatePassword {
  final String new_password;

   UpdatePassword({required this.new_password});

  Map<String, dynamic> toJson() => {'new_password' : new_password};
}