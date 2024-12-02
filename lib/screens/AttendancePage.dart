import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AttendancePage extends StatefulWidget {
  final String courseId;

  const AttendancePage({Key? key, required this.courseId}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final _meetingNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  // Fungsi untuk membuka kelas dan mencatat jadwal pertemuan
  Future<void> _openClass() async {
    final meetingName = _meetingNameController.text.trim();
    final date = _dateController.text.trim();
    final time = _timeController.text.trim();

    if (meetingName.isNotEmpty && date.isNotEmpty && time.isNotEmpty) {
      // Simpan data ke tabel class_opened
      final db = DatabaseHelper.instance;
      try {
        await db.createClassOpened(widget.courseId, meetingName, date, time);

        // Tampilkan notifikasi sukses dan kembali ke halaman sebelumnya
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kelas berhasil dibuka!')),
        );
        Navigator.pop(context);  // Kembali ke halaman sebelumnya
      } catch (e) {
        // Tangani jika terjadi error saat menyimpan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka kelas: $e')),
        );
      }
    } else {
      // Tampilkan error jika ada data yang kosong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi semua field!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buka Kelas Absensi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _meetingNameController,
              decoration: InputDecoration(labelText: 'Nama Pertemuan'),
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
            ),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: 'Jam (HH:mm)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openClass,
              child: Text('Buka Kelas'),
            ),
          ],
        ),
      ),
    );
  }
}
