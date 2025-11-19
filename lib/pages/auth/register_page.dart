import 'package:flutter/material.dart';
import '../../storage/database_helper.dart';
import '../../models/user_model.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/primary_button.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _emailController = TextEditingController();
  final _telpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final newUser = UserModel(
        nama: _namaController.text,
        nik: _nikController.text,
        email: _emailController.text,
        telp: _telpController.text,
        alamat: _alamatController.text,
        username: _usernameController.text,
        password: _passwordController.text, // Belum di-hash (sesuaikan kebutuhan)
      );

      try {
        await DatabaseHelper().insertUser(newUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Registrasi berhasil! Silakan login.')),
          );
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()));
        }
      } catch (e) {
        // Penanganan error (misal: NIK/Username sudah ada)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Registrasi gagal. Username atau NIK mungkin sudah terdaftar. Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInputField(
                controller: _namaController,
                label: 'Nama Lengkap',
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _nikController,
                label: 'NIK (16 Digit)',
                keyboardType: TextInputType.number,
                validator: Validators.validateNik,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _telpController,
                label: 'Nomor Telepon',
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhoneNumber,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _alamatController,
                label: 'Alamat',
                validator: Validators.required,
              ),
              const SizedBox(height: 24),
              const Text('Data Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _usernameController,
                label: 'Username',
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _passwordController,
                label: 'Password (min 6 karakter)',
                isPassword: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 24),
              PrimaryButton(text: 'Daftar', onPressed: _register, isLoading: _isLoading),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Sudah punya akun? Kembali ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}