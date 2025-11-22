import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/transaction_model.dart';
import '../../../storage/database_helper.dart';
import '../../../utils/validators.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/custom_input_field.dart';
import '../../../widgets/primary_button.dart';
import '../../../utils/notifications.dart';

class EditTransactionPage extends StatefulWidget {
  final TransactionModel initialData;
  const EditTransactionPage({super.key, required this.initialData});

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaPenyewaController;
  late TextEditingController _lamaSewaController;
  late TextEditingController _tanggalMulaiController;
  DateTime? _selectedDate;
  int _carPrice = 0;
  int _totalHarga = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaPenyewaController =
        TextEditingController(text: widget.initialData.namaPenyewa);
    _lamaSewaController =
        TextEditingController(text: widget.initialData.lamaSewa.toString());
    _tanggalMulaiController =
        TextEditingController(text: widget.initialData.tanggalMulai);
    _selectedDate = DateTime.parse(widget.initialData.tanggalMulai);

    _loadCarPriceAndCalculate();
    _lamaSewaController.addListener(_calculateTotal);
  }

  Future<void> _loadCarPriceAndCalculate() async {
    final car = await DatabaseHelper().getCarById(widget.initialData.carId);
    if (car != null) {
      _carPrice = car.hargaSewa;
      _calculateTotal();
    }
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
      _totalHarga = lamaSewa * _carPrice;
      // Jika harga mobil belum dimuat, gunakan total harga lama sebagai fallback
      if (_carPrice == 0) _totalHarga = widget.initialData.totalHarga;
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

  Future<void> _updateRental() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        showAppNotification(context, 'Tanggal mulai sewa wajib diisi.', type: NotificationType.error);
        return;
      }
      
      setState(() => _isLoading = true);
      final lamaSewa = int.parse(_lamaSewaController.text);

      final updatedTransaction = TransactionModel(
        id: widget.initialData.id,
        userId: widget.initialData.userId,
        carId: widget.initialData.carId,
        namaPenyewa: _namaPenyewaController.text,
        lamaSewa: lamaSewa,
        tanggalMulai: _tanggalMulaiController.text,
        totalHarga: _totalHarga,
        status: widget.initialData.status, // Status tidak berubah
      );

      await DatabaseHelper().updateTransaction(updatedTransaction);
      
      if (mounted) {
        showAppNotification(context, 'Penyewaan berhasil diperbarui!', type: NotificationType.success);
        // Kembali ke Halaman Detail dengan data baru
        Navigator.pop(context, true);
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Transaksi #${widget.initialData.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Detail Harga (ReadOnly)
              Card(
                color: Colors.yellow.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Harga Sewa / Hari (Tidak dapat diubah):', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(formatRupiah(_carPrice == 0 ? (widget.initialData.totalHarga ~/ widget.initialData.lamaSewa) : _carPrice), style: const TextStyle(fontSize: 16, color: Colors.orange)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Form Input
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

              // Total Harga
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL HARGA BARU', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(formatRupiah(_totalHarga), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(text: 'Simpan Perubahan', onPressed: _updateRental, isLoading: _isLoading),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal & Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}