class Skill {
  final int? id;
  final int userId;
  final String beceriAdi;
  final String tip; // 'ogretir' veya 'ogrenir'

  Skill({
    this.id,
    required this.userId,
    required this.beceriAdi,
    required this.tip,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'beceriAdi': beceriAdi,
      'tip': tip,
    };
  }

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      id: map['id'] as int?,
      userId: map['userId'] as int? ?? 0,
      beceriAdi: map['beceriAdi'] as String? ?? '',
      tip: map['tip'] as String? ?? 'ogretir',
    );
  }
}
