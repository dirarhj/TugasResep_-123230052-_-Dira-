import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Hive.initFlutter();
  await Hive.openBox('favorites'); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ResepKu',
      theme: ThemeData(
        primarySwatch: Colors.orange, 
      ),
      home: const LoginPage(),
    );
  }
}