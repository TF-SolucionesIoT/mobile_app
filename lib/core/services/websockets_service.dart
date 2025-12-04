import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  String baseWssUrl = dotenv.env['WSS_URL'] ?? "ws://10.0.2.2:8081/ws";
  WebSocketChannel? _channel;

  void connect(
    String token,
    void Function(Map<String, dynamic>) onMessage, {
    Function(dynamic)? onError,
    void Function()? onDone,
  }) {
    print("🔌 Conectando al WS...");
    print("URL → $baseWssUrl/monitoring?token=$token");

    _channel = WebSocketChannel.connect(
      Uri.parse("$baseWssUrl/monitoring?token=$token"),
    );

    print("📡 Esperando mensajes...");

    _channel!.stream.listen(
      (msg) {
        print("📥 Mensaje recibido RAW => $msg");
        try {
          final jsonData = jsonDecode(msg);
          print("📦 JSON decodificado => $jsonData");
          onMessage(jsonData);
        } catch (e) {
          print("Error parsing WS message: $e");
        }
      },
      onError: (err) {
        print("🔥 WS error: $err");
        if (onError != null) onError(err);
      },
      onDone: () {
        print("🔌 WS cerrado por el servidor");
        if (onDone != null) onDone();
      },
      cancelOnError: true,
    );
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
