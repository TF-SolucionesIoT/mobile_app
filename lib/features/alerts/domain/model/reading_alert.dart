class ReadingAlert {
  final int id;
  final String deviceId;
  final DateTime timestamp;

  ReadingAlert({
    required this.id,
    required this.deviceId,
    required this.timestamp,
  });

  factory ReadingAlert.fromJson(Map<String, dynamic> json) {
    return ReadingAlert(
      id: json['id'] as int,
      deviceId: json['deviceId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ReadingAlert(id: $id, deviceId: $deviceId, timestamp: $timestamp)';
  }
}