class SwapRequest {
  final int? id;
  final int gonderenId;
  final int aliciId;
  final String tip; // 'takas' veya 'ucretli'
  final String durum; // 'bekliyor', 'kabul', 'red'
  final String mesaj;
  final String tarih;

  SwapRequest({
    this.id,
    required this.gonderenId,
    required this.aliciId,
    required this.tip,
    this.durum = 'bekliyor',
    this.mesaj = '',
    required this.tarih,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'gonderenId': gonderenId,
      'aliciId': aliciId,
      'tip': tip,
      'durum': durum,
      'mesaj': mesaj,
      'tarih': tarih,
    };
  }

  factory SwapRequest.fromMap(Map<String, dynamic> map) {
    return SwapRequest(
      id: map['id'] as int?,
      gonderenId: map['gonderenId'] as int? ?? 0,
      aliciId: map['aliciId'] as int? ?? 0,
      tip: map['tip'] as String? ?? 'takas',
      durum: map['durum'] as String? ?? 'bekliyor',
      mesaj: map['mesaj'] as String? ?? '',
      tarih: map['tarih'] as String? ?? '',
    );
  }

  SwapRequest copyWith({String? durum}) {
    return SwapRequest(
      id: id,
      gonderenId: gonderenId,
      aliciId: aliciId,
      tip: tip,
      durum: durum ?? this.durum,
      mesaj: mesaj,
      tarih: tarih,
    );
  }
}
