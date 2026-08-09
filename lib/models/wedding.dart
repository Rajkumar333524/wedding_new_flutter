class Wedding {
  final int id;

  final String brideNameEn;
  final String groomNameEn;

  final String brideNameHi;
  final String groomNameHi;

  final String location;
  final String date;

  Wedding({
    required this.id,
    required this.brideNameEn,
    required this.groomNameEn,
    required this.brideNameHi,
    required this.groomNameHi,
    required this.location,
    required this.date,
  });

  // ============================================================
  // BACKEND → APP
  // ============================================================

  factory Wedding.fromJson(Map<String, dynamic> j) {
    return Wedding(
      id: int.tryParse(
            j['id']?.toString() ?? '0',
          ) ??
          0,

      brideNameEn:
          j['bride_name_en']?.toString() ??
          j['bride_name']?.toString() ??
          '',

      groomNameEn:
          j['groom_name_en']?.toString() ??
          j['groom_name']?.toString() ??
          '',

      brideNameHi:
          j['bride_name_hi']?.toString() ??
          j['bride_name']?.toString() ??
          '',

      groomNameHi:
          j['groom_name_hi']?.toString() ??
          j['groom_name']?.toString() ??
          '',

      location: j['location']?.toString() ?? '',

      date: j['date']?.toString() ?? '',
    );
  }

  // ============================================================
  // APP → BACKEND
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'bride_name': brideNameEn,
      'groom_name': groomNameEn,
      'location': location,
      'date': date,
    };
  }
}