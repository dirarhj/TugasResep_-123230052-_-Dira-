import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Wajib ditambahin kalau main() pakai async
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Inisialisasi Hive
  await Hive.initFlutter();
  
  // Buka "Box" (kayak tabel di database) buat nyimpen favorit
  await Hive.openBox('favorites'); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResepKu',
      theme: ThemeData(
        primarySwatch: Colors.orange, // Sesuaiin sama UI di soal
      ),
      home: const LoginPage(),
    );
  }
}