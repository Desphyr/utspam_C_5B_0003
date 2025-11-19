class UserModel {
  final int? id;
  final String nama;
  final String nik;
  final String email;
  final String telp;
  final String alamat;
  final String username;
  final String password;

  UserModel({
    this.id,
    required this.nama,
    required this.nik,
    required this.email,
    required this.telp,
    required this.alamat,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'nik': nik,
      'email': email,
      'telp': telp,
      'alamat': alamat,
      'username': username,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      nama: map['nama'],
      nik: map['nik'],
      email: map['email'],
      telp: map['telp'],
      alamat: map['alamat'],
      username: map['username'],
      password: map['password'],
    );
  }
}