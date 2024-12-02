import 'package:flutter/material.dart';
import 'package:uasmobprogfinal/screens/AttendancePage.dart';
import '../models/user.dart';
import '../database/database_helper.dart';
import 'AttendancePage.dart';

class ClassDetailsPage extends StatefulWidget {
  final String courseId;

  const ClassDetailsPage({Key? key, required this.courseId}) : super(key: key);

  @override
  _ClassDetailsPageState createState() => _ClassDetailsPageState();
}

class _ClassDetailsPageState extends State<ClassDetailsPage> {
  List<User> _students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final db = DatabaseHelper.instance;
    final students = await db.getStudentsInCourse(widget.courseId);
    setState(() {
      _students = students;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Mahasiswa Mata Kuliah'),
      ),
      body: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return Card(
            child: ListTile(
              title: Text(student.name),
              subtitle: Text('NPM: ${student.npm}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman untuk membuka kelas dan input data absensi
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttendancePage(courseId: widget.courseId),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Buka Kelas',
      ),
    );
  }
}
