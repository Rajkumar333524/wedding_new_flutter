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

  /// 🔽 BACKEND → APP (Crash-Proof)
  factory Wedding.fromJson(Map<String, dynamic> j) {
    return Wedding(
      id: j['id'] ?? 0,

      brideNameEn: j['bride_name_en'] ?? '',
      groomNameEn: j['groom_name_en'] ?? '',

      brideNameHi: j['bride_name_hi'] ?? '',
      groomNameHi: j['groom_name_hi'] ?? '',

      location: j['location'] ?? '',
      date: j['date'] ?? '',
    );
  }

  /// 🔼 APP → BACKEND (100% Compatible)
  Map<String, dynamic> toJson() => {
        "id": id,

        "bride_name_en": brideNameEn,
        "groom_name_en": groomNameEn,

        "bride_name_hi": brideNameHi,
        "groom_name_hi": groomNameHi,

        "location": location,
        "date": date,
      };
}
