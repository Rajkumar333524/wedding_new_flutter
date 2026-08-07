class TakenEntry {
  final int id;
  final int weddingId;
  final String personName;     // ladki ke papa, mama, etc
  final double amount;        // kitna liya
  final DateTime date;

  TakenEntry({
    required this.id,
    required this.weddingId,
    required this.personName,
    required this.amount,
    required this.date,
  });

  // 🧯 HIVE-SAFE factory (32-bit safe id)
  factory TakenEntry.fromJson(Map<String, dynamic> j) => TakenEntry(
        id: (j['id'] ?? DateTime.now().millisecondsSinceEpoch) % 0xFFFFFFFF,
        weddingId: j['wedding_id'],
        personName: j['person'],
        amount: double.tryParse(j['amount'].toString()) ?? 0,
        date: DateTime.parse(j['date']),
      );

  Map<String, dynamic> toJson() => {
        // 🧯 Always send safe id to backend & Hive
        "id": id % 0xFFFFFFFF,
        "wedding_id": weddingId,
        "person": personName,
        "amount": amount,
        "date": date.toIso8601String(),
      };
}
