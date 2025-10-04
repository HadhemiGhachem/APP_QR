import 'package:flutter/material.dart';
import 'package:qr_app_new/Home.dart';
import 'auth/Login.dart';
import 'auth/Register.dart';
import 'ExcelDisplayScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/home': (context) => const Home(),
        '/excelDisplay': (context) => ExcelDisplayScreen(),
      },
    );
  }
}