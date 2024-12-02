import 'package:flutter/material.dart';
import 'package:uasmobprogfinal/screens/signup_screen.dart';
import 'package:uasmobprogfinal/screens/student_dashboard.dart';

import '../database/database_helper.dart';
import 'lecturer_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _npmController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sistem Absensi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32),
            TextField(
              controller: _npmController,
              decoration: InputDecoration(
                labelText: 'NPM/NIP',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final user = await DatabaseHelper.instance.getUser(
                  _npmController.text,
                  _passwordController.text,
                );

                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => user.role == 'dosen'
                          ? LecturerDashboard(user: user)
                          : StudentDashboard(user: user),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login gagal')),
                  );
                }
              },
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text('Belum punya akun? Daftar disini'),
            ),
          ],
        ),
      ),
    );
  }
}