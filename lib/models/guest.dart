import 'package:hive/hive.dart';

part 'guest.g.dart';

@HiveType(typeId: 1)
class Guest {
  @HiveField(0)
  final int localId;

  @HiveField(1)
  final int backendId;

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

  @HiveField(12)
  final double taken;

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
    required this.taken,
    required this.type,
    required this.date,
  });

  // ============================================================
  // BACKEND → APP
  // Supports both old Django fields and new Flutter fields
  // ============================================================

  factory Guest.fromJson(Map<String, dynamic> j) {
    final int parsedBackendId =
        int.tryParse(j['id']?.toString() ?? '0') ?? 0;

    final int parsedWeddingId =
        int.tryParse(j['wedding_id']?.toString() ?? '0') ?? 0;

    final int parsedLocalId =
        int.tryParse(j['local_id']?.toString() ?? '0') ??
        (parsedBackendId > 0
            ? parsedBackendId
            : DateTime.now().millisecondsSinceEpoch);

    final double amount =
        double.tryParse(
              j['given']?.toString() ??
                  j['amount']?.toString() ??
                  '0',
            ) ??
            0;

    final double takenAmount =
        double.tryParse(
              j['taken']?.toString() ?? '0',
            ) ??
            0;

    return Guest(
      localId: parsedLocalId,

      backendId: parsedBackendId,

      weddingId: parsedWeddingId,

      nameEn:
          j['name_en']?.toString() ??
          j['name']?.toString() ??
          '',

      nameHi:
          j['name_hi']?.toString() ??
          j['name']?.toString() ??
          '',

      addressEn:
          j['address_en']?.toString() ??
          j['address']?.toString() ??
          '',

      addressHi:
          j['address_hi']?.toString() ??
          j['address']?.toString() ??
          '',

      giftEn:
          j['gift_en']?.toString() ??
          j['gift']?.toString() ??
          '',

      giftHi:
          j['gift_hi']?.toString() ??
          j['gift']?.toString() ??
          '',

      given: amount,

      taken: takenAmount,

      type:
          j['type']?.toString() ??
          'Given',

      date: j['date'] != null
          ? DateTime.tryParse(
                j['date'].toString(),
              ) ??
              DateTime.now()
          : DateTime.now(),
    );
  }

  // ============================================================
  // APP → BACKEND
  // Compatible with current Django Guest API
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': backendId,
      'wedding_id': weddingId,

      // Current Django backend fields
      'name': nameEn.isNotEmpty
          ? nameEn
          : nameHi,

      'address': addressEn.isNotEmpty
          ? addressEn
          : addressHi,

      'gift': giftEn.isNotEmpty
          ? giftEn
          : giftHi,

      'amount': given,

      // Extra fields can remain available
      // for a future upgraded backend.
      'name_en': nameEn,
      'name_hi': nameHi,
      'address_en': addressEn,
      'address_hi': addressHi,
      'gift_en': giftEn,
      'gift_hi': giftHi,
      'given': given,
      'taken': taken,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

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
    double? taken,
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
      taken: taken ?? this.taken,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }
}