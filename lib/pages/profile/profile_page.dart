import 'package:flutter/material.dart';
import '../../../storage/database_helper.dart';
import '../../../models/user_model.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<UserModel?>? _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = DatabaseHelper().getUserById(widget.userId);
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          const Text(': '),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna')),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Gagal memuat data pengguna.'));
          }

          final user = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Icon(Icons.account_circle, size: 80, color: Colors.blue),
                    ),
                    const Divider(height: 30),
                    Text('Data Diri', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    const SizedBox(height: 10),
                    _buildProfileRow('Nama', user.nama),
                    _buildProfileRow('NIK', user.nik),
                    _buildProfileRow('Email', user.email),
                    _buildProfileRow('Telepon', user.telp),
                    _buildProfileRow('Alamat', user.alamat),
                    
                    const Divider(height: 30),
                    Text('Data Akun', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    const SizedBox(height: 10),
                    _buildProfileRow('Username', user.username),
                    _buildProfileRow('Password', '********'), // Jangan tampilkan password asli
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}