class Course {
  final String id;
  final String name;
  final String lecturerNpm;

  Course({
    required this.id,
    required this.name,
    required this.lecturerNpm,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lecturer_npm': lecturerNpm,
    };
  }
}
