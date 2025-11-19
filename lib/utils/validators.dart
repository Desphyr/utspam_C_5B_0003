class Validators {
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bidang ini wajib diisi';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Hanya angka yang diperbolehkan';
    }
    if (value.length < 8) {
      return 'Nomor telepon minimal 8 angka';
    }
    return null;
  }

  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < minLength) {
      return 'Password minimal $minLength karakter';
    }
    return null;
  }

  static String? validateNik(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIK wajib diisi';
    }
    final nikRegex = RegExp(r'^[0-9]{16}$');
    if (!nikRegex.hasMatch(value)) {
      return 'NIK harus 16 digit angka';
    }
    return null;
  }
  
  static String? validateLamaSewa(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lama sewa wajib diisi';
    }
    final days = int.tryParse(value);
    if (days == null || days < 1) {
      return 'Lama sewa minimal 1 hari';
    }
    return null;
  }
}