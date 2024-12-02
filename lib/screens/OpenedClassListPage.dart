import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import 'StudentAttendancePage.dart';

class OpenedClassListPage extends StatefulWidget {
  final String lecturerNpm;

  const OpenedClassListPage({Key? key, required this.lecturerNpm}) : super(key: key);

  @override
  _OpenedClassListPageState createState() => _OpenedClassListPageState();
}

class _OpenedClassListPageState extends State<OpenedClassListPage> {
  late Future<List<Map<String, dynamic>>> _classOpenedList;

  @override
  void initState() {
    super.initState();
    _classOpenedList = DatabaseHelper.instance.getClassOpenedByLecturer(widget.lecturerNpm);
  }

  Future<void> _deleteClass(String courseId, String meetingName, String date) async {
    try {
      // Menggunakan method baru yang mencakup notifikasi
      await DatabaseHelper.instance.deleteClassOpenedWithNotification(courseId, meetingName, date);
      setState(() {
        _classOpenedList = DatabaseHelper.instance.getClassOpenedByLecturer(widget.lecturerNpm);
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kelas berhasil dihapus'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus kelas'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Kelas Terbuka'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _classOpenedList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Terjadi kesalahan: ${snapshot.error}')
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('Tidak ada kelas terbuka')
            );
          }

          final classOpenedList = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: classOpenedList.length,
            itemBuilder: (context, index) {
              final classOpened = classOpenedList[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentAttendancePage(
                          courseId: classOpened['course_id']
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mata Kuliah: ${classOpened['course_id']}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pertemuan: ${classOpened['meeting_name']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    'Tanggal: ${classOpened['date']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    'Jam: ${classOpened['time']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Konfirmasi'),
                                      content: Text('Apakah Anda yakin ingin menghapus kelas ini?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Batal'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Hapus'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _deleteClass(
                                                classOpened['course_id'],
                                                classOpened['meeting_name'],
                                                classOpened['date']
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
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