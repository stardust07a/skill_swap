class Message {
  final int? id;
  final int gonderenId;
  final int aliciId;
  final String metin;
  final String tarih;

  Message({
    this.id,
    required this.gonderenId,
    required this.aliciId,
    required this.metin,
    required this.tarih,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'gonderenId': gonderenId,
      'aliciId': aliciId,
      'metin': metin,
      'tarih': tarih,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int?,
      gonderenId: map['gonderenId'] as int? ?? 0,
      aliciId: map['aliciId'] as int? ?? 0,
      metin: map['metin'] as String? ?? '',
      tarih: map['tarih'] as String? ?? '',
    );
  }
}
