import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketController extends GetxController {
  WebSocketChannel? _channel;
  var messageStream = Rx<String?>(null); // Observable for messages

  @override
  void onInit() {
    super.onInit();
    // Initialize WebSocket connection when the controller is created
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://${dotenv.env['SOCKET_URL']}/api/ws'), // WebSocket URL
    );

    // Listen to incoming messages and update messageStream
    _channel?.stream.listen((message) {
      messageStream.value = message;
    });
  }

  @override
  void onClose() {
    super.onClose();
    _channel?.sink.close(); // Clean up when the controller is disposed
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel?.sink.add(message); // Send message to WebSocket server
    }
  }
}
