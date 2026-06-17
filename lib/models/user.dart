class User {
  final int? id;
  final String ad;
  final String email;
  final String sifre;
  final String sehir;
  final String ilce;
  final String bio;
  final bool isAdmin;

  User({
    this.id,
    required this.ad,
    required this.email,
    required this.sifre,
    required this.sehir,
    required this.ilce,
    this.bio = '',
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ad': ad,
      'email': email,
      'sifre': sifre,
      'sehir': sehir,
      'ilce': ilce,
      'bio': bio,
      'isAdmin': isAdmin ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      ad: map['ad'] as String? ?? '',
      email: map['email'] as String? ?? '',
      sifre: map['sifre'] as String? ?? '',
      sehir: map['sehir'] as String? ?? '',
      ilce: map['ilce'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      isAdmin: (map['isAdmin'] as int? ?? 0) == 1,
    );
  }

  User copyWith({
    int? id,
    String? ad,
    String? email,
    String? sifre,
    String? sehir,
    String? ilce,
    String? bio,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      email: email ?? this.email,
      sifre: sifre ?? this.sifre,
      sehir: sehir ?? this.sehir,
      ilce: ilce ?? this.ilce,
      bio: bio ?? this.bio,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
