import 'package:hive/hive.dart';

part 'guest.g.dart';

@HiveType(typeId: 1)
class Guest {
  @HiveField(0)
  final int localId;        // 🔵 Hive local id

  @HiveField(1)
  final int backendId;     // 🟢 Django primary key

  @HiveField(2)
  final int weddingId;

  @HiveField(3)
  final String nameEn;

  @HiveField(4)
  final String nameHi;

  @HiveField(5)
  final String addressEn;

  @HiveField(6)
  final String addressHi;

  @HiveField(7)
  final String giftEn;

  @HiveField(8)
  final String giftHi;

  @HiveField(9)
  final double given;

  @HiveField(10)
  final String type;

  @HiveField(11)
  final DateTime date;

  Guest({
    required this.localId,
    required this.backendId,
    required this.weddingId,
    required this.nameEn,
    required this.nameHi,
    required this.addressEn,
    required this.addressHi,
    required this.giftEn,
    required this.giftHi,
    required this.given,
    required this.type,
    required this.date,
  });

  // 🔄 JSON → Dart
  factory Guest.fromJson(Map<String, dynamic> j) => Guest(
        localId: DateTime.now().millisecondsSinceEpoch,   // local only
        backendId: j['id'],                              // real DB id
        weddingId: j['wedding_id'],
        nameEn: j['name_en'] ?? '',
        nameHi: j['name_hi'] ?? '',
        addressEn: j['address_en'] ?? '',
        addressHi: j['address_hi'] ?? '',
        giftEn: j['gift_en'] ?? '',
        giftHi: j['gift_hi'] ?? '',
        given: double.tryParse(j['given'].toString()) ?? 0,
        type: (j['type'] ?? 'Given').toString(),
        date: j['date'] != null
            ? DateTime.tryParse(j['date'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );

  // 🔄 Dart → JSON (for API)
  Map<String, dynamic> toJson() => {
        "id": backendId,               // 🧠 very important
        "wedding_id": weddingId,
        "name_en": nameEn,
        "name_hi": nameHi,
        "address_en": addressEn,
        "address_hi": addressHi,
        "gift_en": giftEn,
        "gift_hi": giftHi,
        "given": given,
        "type": type,
        "date": date.toIso8601String(),
      };

  Guest copyWith({
    int? localId,
    int? backendId,
    int? weddingId,
    String? nameEn,
    String? nameHi,
    String? addressEn,
    String? addressHi,
    String? giftEn,
    String? giftHi,
    double? given,
    String? type,
    DateTime? date,
  }) {
    return Guest(
      localId: localId ?? this.localId,
      backendId: backendId ?? this.backendId,
      weddingId: weddingId ?? this.weddingId,
      nameEn: nameEn ?? this.nameEn,
      nameHi: nameHi ?? this.nameHi,
      addressEn: addressEn ?? this.addressEn,
      addressHi: addressHi ?? this.addressHi,
      giftEn: giftEn ?? this.giftEn,
      giftHi: giftHi ?? this.giftHi,
      given: given ?? this.given,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }
}
