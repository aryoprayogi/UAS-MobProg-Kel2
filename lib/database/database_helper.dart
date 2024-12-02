import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/attendance.dart';
import '../models/course.dart';
import '../models/notification.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('attendance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        npm TEXT NOT NULL,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE courses(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        lecturer_npm TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE course_students(
        course_id TEXT,
        student_npm TEXT,
        PRIMARY KEY (course_id, student_npm)
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_npm TEXT NOT NULL,
        course_id TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        location TEXT NOT NULL
      )
    ''');


    await db.execute('''
      CREATE TABLE class_opened(
        course_id TEXT,
        meeting_name TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        PRIMARY KEY (course_id, meeting_name, date)
      )
    ''');


    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_npm TEXT NOT NULL,
        course_id TEXT NOT NULL,
        meeting_name TEXT NOT NULL,
        date TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');


  }

  // User operations
  Future<User> createUser(User user) async {
    final db = await instance.database;
    final id = await db.insert('users', user.toMap());
    return user;
  }

  Future<User?> getUser(String npm, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'npm = ? AND password = ?',
      whereArgs: [npm, password],
    );

    if (maps.isNotEmpty) {
      return User(
        id: maps.first['id'] as int,
        npm: maps.first['npm'] as String,
        name: maps.first['name'] as String,
        role: maps.first['role'] as String,
        password: maps.first['password'] as String,
      );
    }
    return null;
  }

  // Attendance operations
  Future<int> createAttendance(Attendance attendance) async {
    final db = await instance.database;
    return await db.insert('attendance', attendance.toMap());
  }

  Future<List<Map<String, dynamic>>> getStudentAttendance(
      String studentNpm, String courseId) async {
    final db = await instance.database;
    return await db.query(
      'attendance',
      where: 'student_npm = ? AND course_id = ?',
      whereArgs: [studentNpm, courseId],
    );
  }


  Future<void> createCourse(Course course) async {
    final db = await instance.database;
    await db.insert('courses', course.toMap());
  }


  Future<List<Course>> getCoursesByLecturer(String lecturerNpm) async {
    final db = await instance.database;
    final maps = await db.query(
      'courses',
      where: 'lecturer_npm = ?',
      whereArgs: [lecturerNpm],
    );

    return List.generate(maps.length, (i) {
      return Course(
        id: maps[i]['id'] as String,
        name: maps[i]['name'] as String,
        lecturerNpm: maps[i]['lecturer_npm'] as String,
      );
    });
  }


  Future<List<User>> getUsersByRole(String role) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [role],
    );

    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'] as int,
        npm: maps[i]['npm'] as String,
        name: maps[i]['name'] as String,
        role: maps[i]['role'] as String,
        password: maps[i]['password'] as String,
      );
    });
  }


  Future<List<User>> getStudentsInCourse(String courseId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
    SELECT users.* FROM users
    INNER JOIN course_students ON users.npm = course_students.student_npm
    WHERE course_students.course_id = ?
  ''', [courseId]);

    return result
        .map((map) => User(
      id: map['id'] as int,
      npm: map['npm'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      password: map['password'] as String,
    ))
        .toList();
  }


  Future<void> addStudentToCourse(String courseId, String studentNpm) async {
    final db = await instance.database;
    await db.insert('course_students', {
      'course_id': courseId,
      'student_npm': studentNpm,
    });
  }





  Future<void> createClassOpened(String courseId, String meetingName, String date, String time) async {
    final db = await instance.database;
    try {
      await db.insert('class_opened', {
        'course_id': courseId,
        'meeting_name': meetingName,
        'date': date,
        'time': time,
      });
    } catch (e) {

      throw Exception('Gagal menambahkan kelas yang dibuka: $e');
    }
  }






  Future<List<Map<String, dynamic>>> getClassOpened(String courseId) async {
    final db = await instance.database;
    return await db.query(
      'class_opened',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
  }




  Future<bool> canAttendClass(String studentNpm, String courseId, String meetingName) async {
    final db = DatabaseHelper.instance;


    final classOpened = await db.getClassOpened(courseId);

    if (classOpened.isEmpty) {
      return false;
    }


    final students = await db.getStudentsInCourse(courseId);
    final isStudentRegistered = students.any((student) => student.npm == studentNpm);

    return isStudentRegistered;
  }






  Future<List<Map<String, dynamic>>> getClassOpenedByLecturer(String lecturerNpm) async {
    final db = await instance.database;
    return await db.query(
      'class_opened',
      where: 'course_id IN (SELECT id FROM courses WHERE lecturer_npm = ?)',
      whereArgs: [lecturerNpm],
    );
  }


  Future<void> deleteClassOpened(String courseId, String meetingName, String date) async {
    final db = await instance.database;
    await db.delete(
      'class_opened',
      where: 'course_id = ? AND meeting_name = ? AND date = ?',
      whereArgs: [courseId, meetingName, date],
    );
  }




  Future<void> updateAttendanceStatus(String studentNpm, String courseId, String meetingName) async {
    final db = await instance.database;

    // Update status absensi menjadi 'Hadir'
    await db.update(
      'attendance',
      {'status': 'Hadir', 'location': 'Lokasi Absen', 'date': 'Tanggal Absen'},
      where: 'student_npm = ? AND course_id = ? AND meeting_name = ?',
      whereArgs: [studentNpm, courseId, meetingName],
    );
  }







  Future<List<Map<String, dynamic>>> getClassOpenedForStudent(String studentNpm) async {
    final db = await instance.database;

    // Query untuk mengambil kelas yang sudah dibuka beserta meeting_name
    final result = await db.rawQuery('''
    SELECT class_opened.course_id, courses.name AS course_name, class_opened.time, class_opened.meeting_name, class_opened.date
    FROM class_opened
    INNER JOIN courses ON class_opened.course_id = courses.id
    INNER JOIN course_students ON courses.id = course_students.course_id
    WHERE course_students.student_npm = ?
  ''', [studentNpm]);

    return result;
  }





  Future<int> deleteCourse(String courseId) async {
    final db = await instance.database;
    return await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [courseId],
    );
  }




  Future<int> removeStudentFromCourse(String courseId, String studentNpm) async {
    final db = await instance.database;
    return await db.delete(
      'course_students', // Tabel relasi antara course dan student
      where: 'course_id = ? AND student_npm = ?',
      whereArgs: [courseId, studentNpm],
    );
  }





  Future<bool> checkAttendance(String studentNpm, String courseId, String date) async {
    final db = await database;
    final result = await db.query(
      'attendance',
      where: 'student_npm = ? AND course_id = ? AND date = ?',
      whereArgs: [studentNpm, courseId, date],
    );


    return result.isNotEmpty;
  }














  Future<void> createNotificationForUnattendedStudents(
      String courseId,
      String meetingName,
      String date,
      String message,
      ) async {
    final db = await database;


    final students = await getStudentsInCourse(courseId);


    for (var student in students) {
      final hasAttended = await checkAttendance(student.npm, courseId, date);


      if (!hasAttended) {
        final notification = {
          'student_npm': student.npm,
          'course_id': courseId,
          'meeting_name': meetingName,
          'date': date,
          'message': message,
          'created_at': DateTime.now().toIso8601String(),
        };

        await db.insert('notifications', notification);
      }
    }
  }


  Future<List<Map<String, dynamic>>> getStudentNotifications(String studentNpm) async {
    final db = await database;
    return await db.query(
      'notifications',
      where: 'student_npm = ?',
      whereArgs: [studentNpm],
      orderBy: 'created_at DESC',
    );
  }


  Future<void> deleteNotification(int notificationId) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }





  Future<void> deleteClassOpenedWithNotification(String courseId, String meetingName, String date) async {
    final db = await database;


    final students = await getStudentsInCourse(courseId);

    // Buat daftar siswa yang belum absen
    List<String> absentStudents = [];
    for (var student in students) {
      final hasAttended = await checkAttendance(student.npm, courseId, date);
      if (!hasAttended) {
        absentStudents.add(student.npm);
      }
    }


    for (String studentNpm in absentStudents) {
      final notification = {
        'student_npm': studentNpm,
        'course_id': courseId,
        'meeting_name': meetingName,
        'date': date,
        'message': 'Anda belum melakukan absensi untuk kelas $meetingName pada tanggal $date.',
        'created_at': DateTime.now().toIso8601String(),
      };

      await db.insert('notifications', notification);
    }


    await db.delete(
      'attendance',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );


    await db.delete(
      'class_opened',
      where: 'course_id = ? AND meeting_name = ? AND date = ?',
      whereArgs: [courseId, meetingName, date],
    );
  }





}