import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:car_rent_app/storage/database_helper.dart';
import 'package:car_rent_app/models/user_model.dart';
import '../main_navigation.dart';
import 'package:car_rent_app/pages/auth/register_page.dart';
import 'package:car_rent_app/widgets/custom_input_field.dart';
import 'package:car_rent_app/widgets/primary_button.dart';

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

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('currentUserId', user.id!);
        await prefs.setString('currentUserName', user.nama);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Username/NIK atau Password salah.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                
                Image.asset(
                  'assets/images/logo.png',
                  height: 200, 
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                
                const Text(
                  'Sewa Mobil Mudah dan Terpercaya',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 50),

                CustomInputField(
                  controller: _loginIdController,
                  label: 'Username atau NIK',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                CustomInputField(
                  controller: _passwordController,
                  label: 'Password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),

                PrimaryButton(text: 'Masuk', onPressed: _login, isLoading: _isLoading),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun? ', style: TextStyle(color: Colors.black54)),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const RegisterPage()));
                      },
                      child: Text('Daftar Sekarang',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}