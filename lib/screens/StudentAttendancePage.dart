import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class StudentAttendancePage extends StatefulWidget {
  final String courseId;

  const StudentAttendancePage({Key? key, required this.courseId}) : super(key: key);

  @override
  _StudentAttendancePageState createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  late Future<List<User>> _studentsList;

  @override
  void initState() {
    super.initState();
    _studentsList = DatabaseHelper.instance.getStudentsInCourse(widget.courseId);
  }

  Future<void> _updateAttendanceStatus(String studentNpm) async {
    try {
      await DatabaseHelper.instance.updateAttendanceStatus(studentNpm, widget.courseId, "meeting_name");
      setState(() {
        _studentsList = DatabaseHelper.instance.getStudentsInCourse(widget.courseId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui status kehadiran')));
    }
  }

  Future<Map<String, dynamic>> _getAttendanceDateAndStatus(String studentNpm) async {
    final attendanceList = await DatabaseHelper.instance.getStudentAttendance(studentNpm, widget.courseId);
    if (attendanceList.isNotEmpty) {
      final attendance = attendanceList.first;
      return {
        'date': 'Tanggal: ${attendance['date']}',
        'location': 'Lokasi: ${attendance['location']}',
        'status': attendance['status'] == 'hadir',  // Jika status "hadir" maka true, jika tidak hadir false
      };
    }
    return {
      'date': 'Belum Melakukan Absensi',
      'location': '',
      'status': false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Siswa Kehadiran'),
      ),
      body: FutureBuilder<List<User>>(
        future: _studentsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada siswa terdaftar'));
          }

          final studentsList = snapshot.data!;

          return ListView.builder(
            itemCount: studentsList.length,
            itemBuilder: (context, index) {
              final student = studentsList[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(student.name),
                  subtitle: FutureBuilder<Map<String, dynamic>>(
                    future: _getAttendanceDateAndStatus(student.npm),
                    builder: (context, dateLocationSnapshot) {
                      if (dateLocationSnapshot.connectionState == ConnectionState.waiting) {
                        return Text('Status Kehadiran: Memuat...');
                      }
                      final data = dateLocationSnapshot.data!;
                      return Text(
                        '${data['date']}, ${data['location']}',
                      );
                    },
                  ),
                  trailing: FutureBuilder<Map<String, dynamic>>(
                    future: _getAttendanceDateAndStatus(student.npm),
                    builder: (context, attendanceSnapshot) {
                      if (attendanceSnapshot.connectionState == ConnectionState.waiting) {
                        return Icon(Icons.hourglass_empty);
                      }
                      final isPresent = attendanceSnapshot.data!['status'];
                      return IconButton(
                        icon: Icon(
                          isPresent ? Icons.check : Icons.close,
                          color: isPresent ? Colors.green : Colors.red,  // Warna hijau untuk hadir, merah untuk tidak hadir
                        ),
                        onPressed: () {
                          if (!isPresent) {
                            _updateAttendanceStatus(student.npm);
                          }
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
