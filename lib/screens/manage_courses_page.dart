import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/course.dart';
import 'course_students_page.dart';

class ManageCoursesPage extends StatefulWidget {
  final String lecturerNpm;

  const ManageCoursesPage({Key? key, required this.lecturerNpm}) : super(key: key);

  @override
  _ManageCoursesPageState createState() => _ManageCoursesPageState();
}

class _ManageCoursesPageState extends State<ManageCoursesPage> {
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

  Future<void> _addCourse(String courseId, String courseName) async {
    final db = DatabaseHelper.instance;
    final course = Course(id: courseId, name: courseName, lecturerNpm: widget.lecturerNpm);
    await db.createCourse(course);
    _loadCourses();
  }

  Future<void> _deleteCourse(String courseId) async {
    final db = DatabaseHelper.instance;
    await db.deleteCourse(courseId);
    _loadCourses();
  }

  void _showAddCourseDialog() {
    final idController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Mata Kuliah'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: InputDecoration(labelText: 'ID Mata Kuliah'),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Mata Kuliah'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                final courseId = idController.text.trim();
                final courseName = nameController.text.trim();
                if (courseId.isNotEmpty && courseName.isNotEmpty) {
                  _addCourse(courseId, courseName);
                }
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCourseDialog(String courseId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Mata Kuliah'),
          content: Text('Apakah Anda yakin ingin menghapus mata kuliah ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteCourse(courseId);
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
        title: Text('Kelola Mata Kuliah'),
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
                    builder: (context) => CourseStudentsPage(courseId: course.id),
                  ),
                );
              },
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDeleteCourseDialog(course.id);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        child: Icon(Icons.add),
        tooltip: 'Tambah Mata Kuliah',
      ),
    );
  }
}
