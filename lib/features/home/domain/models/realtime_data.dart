class RealtimeData {
  final String patientId;
  final String userId;
  final int bpm;
  final int spo2;

  RealtimeData({
    required this.patientId,
    required this.userId,
    required this.bpm,
    required this.spo2,
  });

  factory RealtimeData.fromJson(Map<String, dynamic> json) {
    return RealtimeData(
      patientId: json['patient_id'].toString(),
      userId: json['user_id'].toString(),
      bpm: json['bpm'],
      spo2: json['spo2'],
    );
  }
}
