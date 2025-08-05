import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_admin/screens/authenticate/login.dart';
import 'package:frontend_admin/screens/home/home.dart';
import 'package:frontend_admin/screens/wrapper.dart';
import 'package:frontend_admin/shared/constants.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      themeMode: ThemeMode.system,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      routes: {
        '/': (context) => const Wrapper(),
        '/login': (context) => const Login(),
        '/home': (context) => const Home(),
      },
    );
  }
}
