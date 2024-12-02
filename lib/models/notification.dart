class AttendanceNotification {
  final int? id;
  final String studentNpm;
  final String courseId;
  final String meetingName;
  final String date;
  final String message;
  final DateTime createdAt;

  AttendanceNotification({
    this.id,
    required this.studentNpm,
    required this.courseId,
    required this.meetingName,
    required this.date,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_npm': studentNpm,
      'course_id': courseId,
      'meeting_name': meetingName,
      'date': date,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AttendanceNotification.fromMap(Map<String, dynamic> map) {
    return AttendanceNotification(
      id: map['id'] as int,
      studentNpm: map['student_npm'] as String,
      courseId: map['course_id'] as String,
      meetingName: map['meeting_name'] as String,
      date: map['date'] as String,
      message: map['message'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}