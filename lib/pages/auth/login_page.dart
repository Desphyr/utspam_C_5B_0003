import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../storage/database_helper.dart';
import '../../models/user_model.dart';
import '../home/home_page.dart';
import 'register_page.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
        _isLoading = true;
      });

      final dbHelper = DatabaseHelper();
      final String loginId = _loginIdController.text.trim();
      final String password = _passwordController.text;

      UserModel? user = await dbHelper.getUserByUsername(loginId, password);

      if (mounted) {
        setState(() => _isLoading = false);
        if (user != null) {
       
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('currentUserId', user.id!);
          await prefs.setString('currentUserName', user.nama);

  
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          setState(() {
            _errorMessage = 'Username/NIK atau Password salah.';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login CarRentApp', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text('Selamat Datang Kembali!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
      
              CustomInputField(
                controller: _loginIdController,
                label: 'Username atau NIK',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username atau NIK wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            
              CustomInputField(
                controller: _passwordController,
                label: 'Password',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              PrimaryButton(text: 'Login', onPressed: _login, isLoading: _isLoading),
              const SizedBox(height: 20),
              const Divider(),
             
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const RegisterPage()));
                },
                child: const Text('Belum punya akun? Daftar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}