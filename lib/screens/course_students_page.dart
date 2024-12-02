import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class CourseStudentsPage extends StatefulWidget {
  final String courseId;

  const CourseStudentsPage({Key? key, required this.courseId}) : super(key: key);

  @override
  _CourseStudentsPageState createState() => _CourseStudentsPageState();
}

class _CourseStudentsPageState extends State<CourseStudentsPage> {
  List<User> _studentsInCourse = [];

  @override
  void initState() {
    super.initState();
    _loadStudentsInCourse();
  }

  Future<void> _loadStudentsInCourse() async {
    final db = DatabaseHelper.instance;
    final students = await db.getStudentsInCourse(widget.courseId);
    setState(() {
      _studentsInCourse = students;
    });
  }

  Future<void> _removeStudentFromCourse(User student) async {
    final db = DatabaseHelper.instance;
    await db.removeStudentFromCourse(widget.courseId, student.npm);
    _loadStudentsInCourse();
  }

  Future<void> _addStudentToCourse(User student) async {
    final db = DatabaseHelper.instance;
    await db.addStudentToCourse(widget.courseId, student.npm);
    _loadStudentsInCourse();
  }

  void _showAddStudentDialog() async {
    final db = DatabaseHelper.instance;
    final availableStudents = await db.getUsersByRole('mahasiswa');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Mahasiswa'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableStudents.length,
              itemBuilder: (context, index) {
                final student = availableStudents[index];
                return ListTile(
                  title: Text(student.name),
                  subtitle: Text(student.npm),
                  onTap: () {
                    _addStudentToCourse(student);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showRemoveStudentDialog(User student) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Mahasiswa'),
          content: Text('Apakah Anda yakin ingin menghapus mahasiswa ${student.name} dari mata kuliah ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _removeStudentFromCourse(student);
                Navigator.pop(context);
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Mahasiswa'),
      ),
      body: ListView.builder(
        itemCount: _studentsInCourse.length,
        itemBuilder: (context, index) {
          final student = _studentsInCourse[index];
          return Card(
            child: ListTile(
              title: Text(student.name),
              subtitle: Text(student.npm),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showRemoveStudentDialog(student);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        child: Icon(Icons.add),
        tooltip: 'Tambah Mahasiswa',
      ),
    );
  }
}
