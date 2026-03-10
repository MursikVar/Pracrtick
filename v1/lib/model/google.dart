class Google {
  final String id_token;

  Google({required this.id_token});

  Map<String, dynamic> toJson() => {'id_token' : id_token};
}

class GoogleResponse{
  final String access_token;
  final String refresh_token;
  final String token_type;

  GoogleResponse({required this.access_token, required this.refresh_token, required this.token_type});

  factory GoogleResponse.fromJson(Map<String, dynamic> json){
    return GoogleResponse(
      access_token: json['access_token'], 
      refresh_token: json['refresh_token'], 
      token_type: json['token_type']
    );
  }
}