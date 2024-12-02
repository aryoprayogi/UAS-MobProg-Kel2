import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uasmobprogfinal/database/database_helper.dart';
import 'package:uasmobprogfinal/models/attendance.dart';
import 'package:uasmobprogfinal/models/user.dart';
import 'NotificationsTab.dart';
import 'login_screen.dart';

class StudentDashboard extends StatefulWidget {
  final User user;

  const StudentDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Dashboard Mahasiswa' : 'Notifikasi'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang, ${widget.user.name}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                FutureBuilder(
                  future: _loadCourses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Terjadi kesalahan: ${snapshot.error}'),
                      );
                    } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text('Tidak ada kelas yang tersedia untuk hari ini'),
                      );
                    }
                    return Column(
                      children: snapshot.data!.map<Widget>((course) {
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course['course_name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today, size: 16),
                                              SizedBox(width: 8),
                                              Text(
                                                'Tanggal: ${course['date']}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.access_time, size: 16),
                                              SizedBox(width: 8),
                                              Text(
                                                'Jam: ${course['time']}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.meeting_room, size: 16),
                                              SizedBox(width: 8),
                                              Text(
                                                'Pertemuan: ${course['meeting_name']}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _submitAttendance(context, course),
                                      icon: Icon(Icons.check),
                                      label: Text('Absen'),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          NotificationsTab(studentNpm: widget.user.npm),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadCourses() async {
    final db = DatabaseHelper.instance;
    final courses = await db.getClassOpenedForStudent(widget.user.npm);
    return courses;
  }

  Future _submitAttendance(BuildContext context, Map<String, dynamic> course) async {
    try {
      bool hasAttended = await DatabaseHelper.instance.checkAttendance(
        widget.user.npm,
        course['course_id'],
        course['date'],
      );

      if (hasAttended) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anda sudah melakukan absensi untuk kelas ini')),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = placemarks.isNotEmpty
          ? '${placemarks[0].street}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].postalCode}, ${placemarks[0].country}'
          : 'Alamat tidak ditemukan';

      final attendance = Attendance(
        studentNpm: widget.user.npm,
        courseId: course['course_id'],
        date: DateTime.now(),
        status: 'hadir',
        location: address,
      );

      await DatabaseHelper.instance.createAttendance(attendance);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Absensi berhasil dicatat'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mencatat absensi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}