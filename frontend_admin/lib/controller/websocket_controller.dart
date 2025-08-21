import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketController extends GetxController {
  WebSocketChannel? _channel;
  var messageStream = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _channel = WebSocketChannel.connect(
      Uri.parse('${dotenv.env['SOCKET_URL']}/api/ws')
    );
    _channel?.stream.listen((message) {
      messageStream.value = message;
    });
  }

  @override
  void onClose() {
    super.onClose();
    _channel?.sink.close();
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel?.sink.add(message);
    }
  }
}
