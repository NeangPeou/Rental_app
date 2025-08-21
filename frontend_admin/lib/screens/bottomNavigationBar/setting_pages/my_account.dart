import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_admin/utils/helper.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  late String title;
  WebSocketChannel? channel;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    title = Get.arguments ?? "";
    // Connect to the FastAPI WebSocket server
    channel = WebSocketChannel.connect(
      // Uri.parse('ws://0.0.0.0:8000/api/ws'), // FastAPI WebSocket URL
      Uri.parse('${dotenv.env['SOCKET_URL']}/api/ws'),
    );
  }

  @override
  void dispose() {
    super.dispose();
    channel?.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Helper.sampleAppBar(title, context, null),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7, // Adjust height (70% of screen)
              child: StreamBuilder(
                stream: channel?.stream,
                builder: (context, snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return Center(child: CircularProgressIndicator());
                  // }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.hasData) {
                    // Display received message
                    return ListView(
                      children: [
                        ListTile(
                          title: Text(snapshot.data.toString()),
                        ),
                      ],
                    );
                  }

                  return Center(child: Text('No messages yet.'));
                },
              ),
            ),
            Helper.sampleTextField(context: context, controller: _controller, labelText: 'Enter message', validator: (value) => null),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  // Send the message to the WebSocket server
                  channel?.sink.add(_controller.text);
                  _controller.clear();
                }
              },
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
