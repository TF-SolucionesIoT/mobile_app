class RealtimeData {
  final String patientId;
  final String userId;
  final int bpm;
  final int spo2;
  final int bpSystolic;
  final int bpDiastolic;

  RealtimeData({
    required this.patientId,
    required this.userId,
    required this.bpm,
    required this.spo2,
    required this.bpSystolic,
    required this.bpDiastolic,
  });

  factory RealtimeData.fromJson(Map<String, dynamic> json) {
    return RealtimeData(
      patientId: json['patient_id'].toString(),
      userId: json['user_id'].toString(),
      bpm: json['bpm'],
      spo2: json['spo2'],
      bpSystolic: json['bp_systolic'],
      bpDiastolic: json['bp_diastolic'],
    );
  }
}
