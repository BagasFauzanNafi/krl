class HistoryModel {
  final String stasiunAwal;
  final String stasiunAkhir;
  final List<String> jadwal;

  HistoryModel({
    required this.stasiunAwal,
    required this.stasiunAkhir,
    required this.jadwal,
  });

  // Konversi ke Map (untuk Hive)
  Map<String, dynamic> toMap() {
    return {
      'stasiunAwal': stasiunAwal,
      'stasiunAkhir': stasiunAkhir,
      'jadwal': jadwal,
    };
  }

  // Buat dari Map (untuk Hive)
  factory HistoryModel.fromMap(Map<String, dynamic> map) {
  return HistoryModel(
    stasiunAwal: map['stasiunAwal'] ?? '',  // Beri nilai default jika null
    stasiunAkhir: map['stasiunAkhir'] ?? '',
    jadwal: (map['jadwal'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
  );
}

}
