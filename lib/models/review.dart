class Review {
  final int? id;
  final int yazanId;
  final int hedefId;
  final int puan; // 1-5
  final String yorum;
  final String tarih;

  Review({
    this.id,
    required this.yazanId,
    required this.hedefId,
    required this.puan,
    this.yorum = '',
    required this.tarih,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'yazanId': yazanId,
      'hedefId': hedefId,
      'puan': puan,
      'yorum': yorum,
      'tarih': tarih,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as int?,
      yazanId: map['yazanId'] as int? ?? 0,
      hedefId: map['hedefId'] as int? ?? 0,
      puan: map['puan'] as int? ?? 5,
      yorum: map['yorum'] as String? ?? '',
      tarih: map['tarih'] as String? ?? '',
    );
  }
}
