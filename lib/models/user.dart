class User {
  final int? id;
  final String npm;
  final String name;
  final String role; // 'dosen' atau 'mahasiswa'
  final String password;

  User({
    this.id,
    required this.npm,
    required this.name,
    required this.role,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'npm': npm,
      'name': name,
      'role': role,
      'password': password,
    };
  }
}