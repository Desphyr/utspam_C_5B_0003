import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/car_model.dart';
import '../../../models/transaction_model.dart';
import '../../../storage/database_helper.dart';
import '../../../utils/validators.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/custom_input_field.dart';
import '../../../widgets/primary_button.dart';
import '../main_navigation.dart';
import '../../../utils/notifications.dart';

class CarRentFormPage extends StatefulWidget {
  final CarModel car;
  const CarRentFormPage({super.key, required this.car});

  @override
  State<CarRentFormPage> createState() => _CarRentFormPageState();
}

class _CarRentFormPageState extends State<CarRentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaPenyewaController = TextEditingController();
  final _lamaSewaController = TextEditingController();
  final TextEditingController _tanggalMulaiController = TextEditingController();
  DateTime? _selectedDate;
  int _totalHarga = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _lamaSewaController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _lamaSewaController.removeListener(_calculateTotal);
    _lamaSewaController.dispose();
    _namaPenyewaController.dispose();
    _tanggalMulaiController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final lamaSewa = int.tryParse(_lamaSewaController.text) ?? 0;
    setState(() {
      _totalHarga = lamaSewa * widget.car.hargaSewa;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalMulaiController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitRental() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        showAppNotification(context, 'Tanggal mulai sewa wajib diisi.', type: NotificationType.error);
        return;
      }

      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('currentUserId');
      final lamaSewa = int.parse(_lamaSewaController.text);

      if (userId == null) return;

      final newTransaction = TransactionModel(
        userId: userId,
        carId: widget.car.id!,
        namaPenyewa: _namaPenyewaController.text,
        lamaSewa: lamaSewa,
        tanggalMulai: _tanggalMulaiController.text,
        totalHarga: _totalHarga,
        status: 'aktif',
      );

      await DatabaseHelper().insertTransaction(newTransaction);

      if (mounted) {
        showAppNotification(context, 'Penyewaan berhasil disimpan!', type: NotificationType.success);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation(initialIndex: 2)),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sewa ${widget.car.namaMobil}'),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.car.namaMobil,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Jenis: ${widget.car.jenisMobil}'),
                      const Divider(),
                      Text(
                          'Harga Sewa / Hari: ${formatRupiah(widget.car.hargaSewa)}',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.red)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomInputField(
                controller: _namaPenyewaController,
                label: 'Nama Penyewa',
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _lamaSewaController,
                label: 'Lama Sewa (Hari)',
                keyboardType: TextInputType.number,
                validator: Validators.validateLamaSewa,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: CustomInputField(
                    controller: _tanggalMulaiController,
                    label: 'Tanggal Mulai Sewa',
                    hint: 'Pilih Tanggal',
                    validator: Validators.required,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL HARGA',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(formatRupiah(_totalHarga),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                  text: 'Konfirmasi Sewa',
                  onPressed: _submitRental,
                  isLoading: _isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
