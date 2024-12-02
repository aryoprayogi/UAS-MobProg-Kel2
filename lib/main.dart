import 'package:flutter/material.dart';
import 'package:uasmobprogfinal/screens/login_screen.dart';

import 'database/database_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseSeeder.seedDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Absensi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}