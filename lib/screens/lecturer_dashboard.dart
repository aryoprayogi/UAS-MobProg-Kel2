import 'package:flutter/material.dart';
import '../models/user.dart';
import 'OpenClassPage.dart';
import 'OpenedClassListPage.dart';
import 'manage_courses_page.dart';
import 'login_screen.dart';

class LecturerDashboard extends StatefulWidget {
  final User user;

  const LecturerDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _LecturerDashboardState createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Dosen'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // Logout dan kembali ke halaman login
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
      body: _currentIndex == 0
          ? DashboardDosenTab(user: widget.user)
          : KehadiranMahasiswaTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Kehadiran',
          ),
        ],
      ),
    );
  }
}

class DashboardDosenTab extends StatelessWidget {
  final User user;

  const DashboardDosenTab({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat datang, ${user.name}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          Card(
            child: ListTile(
              title: Text('Kelola Mata Kuliah'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to course management
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageCoursesPage(lecturerNpm: user.npm),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Buka Kelas Mahasiswa'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OpenClassPage(lecturerNpm: user.npm),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Lihat Daftar Kelas Terbuka'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to OpenedClassListPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OpenedClassListPage(lecturerNpm: user.npm),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class KehadiranMahasiswaTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Kehadiran Mahasiswa',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                Card(
                  color: Colors.lightBlueAccent,
                  child: ListTile(
                    title: Text(
                      'Kehadiran Mingguan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    subtitle: Text(
                      'Jumlah kehadiran minggu ini: 85%',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  color: Colors.greenAccent,
                  child: ListTile(
                    title: Text(
                      'Kehadiran Bulanan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    subtitle: Text(
                      'Jumlah kehadiran bulan ini: 90%',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: ListTile(
                    title: Text('Persentase Kehadiran'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• Mahasiswa hadir: 120/150'),
                        Text('• Mahasiswa tidak hadir: 30'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
