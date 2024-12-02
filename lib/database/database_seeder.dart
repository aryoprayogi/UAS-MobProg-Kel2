import 'database_helper.dart';
import '../models/user.dart';

class DatabaseSeeder {
  static Future<void> seedDatabase() async {
    // Buat akun default dosen
    final defaultLecturer = User(
      npm: 'D001',
      name: 'Dr. Alvin',
      role: 'dosen',
      password: 'dosen123',
    );



    try {
      await DatabaseHelper.instance.createUser(defaultLecturer);
      print('Database seeded successfully');
    } catch (e) {
      print('Error seeding database: $e');
    }
  }
}