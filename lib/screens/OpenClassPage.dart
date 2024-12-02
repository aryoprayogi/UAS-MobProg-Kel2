import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/user.dart';
import '../database/database_helper.dart';
import 'ClassDetailsPage.dart';

class OpenClassPage extends StatefulWidget {
  final String lecturerNpm;

  const OpenClassPage({Key? key, required this.lecturerNpm}) : super(key: key);

  @override
  _OpenClassPageState createState() => _OpenClassPageState();
}

class _OpenClassPageState extends State<OpenClassPage> {
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final db = DatabaseHelper.instance;
    final courses = await db.getCoursesByLecturer(widget.lecturerNpm);
    setState(() {
      _courses = courses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buka Kelas Mahasiswa'),
      ),
      body: ListView.builder(
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return Card(
            child: ListTile(
              title: Text(course.name),
              subtitle: Text('ID: ${course.id}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassDetailsPage(courseId: course.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
