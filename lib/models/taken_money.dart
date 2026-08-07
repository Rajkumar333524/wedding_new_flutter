class TakenMoney {
  final int id;
  final int weddingId;

  // 👤 Name
  final String personNameEn;
  final String personNameHi;

  // 🏠 Address
  final String addressEn;
  final String addressHi;

  // 💰 Amount
  final double amount;

  TakenMoney({
    required this.id,
    required this.weddingId,
    required this.personNameEn,
    required this.personNameHi,
    required this.addressEn,
    required this.addressHi,
    required this.amount,
  });

  /// 🔽 BACKEND → APP
  factory TakenMoney.fromJson(Map<String, dynamic> j) {
    return TakenMoney(
      id: j['id'] ?? 0,
      weddingId: j['wedding_id'] ?? 0,

      personNameEn: j['person_name_en'] ?? '',
      personNameHi: j['person_name_hi'] ?? '',

      addressEn: j['address_en'] ?? '',
      addressHi: j['address_hi'] ?? '',

      amount: _toDouble(j['amount']),
    );
  }

  /// 🔼 APP → BACKEND
  Map<String, dynamic> toJson() => {
        "id": id,
        "wedding_id": weddingId,

        "person_name_en": personNameEn,
        "person_name_hi": personNameHi,

        "address_en": addressEn,
        "address_hi": addressHi,

        "amount": amount,
      };

  // 🛡️ Universal safe number conversion
  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return double.tryParse(v.toString()) ?? 0;
  }
}
