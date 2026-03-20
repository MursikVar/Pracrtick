class TotpKey {
  final String totpkey;

  TotpKey({required this.totpkey});

  factory TotpKey.fromJson(Map<String, dynamic> json) {
    return TotpKey(totpkey: json['totpkey']);
  }
}

class TotpKeyGenerate{
  final String secret;

  TotpKeyGenerate({required this.secret});

  Map<String, dynamic> toJson() => {
    'secret' : secret
  };
}
