class Attendance {
  final int? id;
  final String studentNpm;
  final String courseId;
  final DateTime date;
  final String status;
  final String location;

  Attendance({
    this.id,
    required this.studentNpm,
    required this.courseId,
    required this.date,
    required this.status,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_npm': studentNpm,
      'course_id': courseId,
      'date': date.toIso8601String(),
      'status': status,
      'location': location,
    };
  }
}