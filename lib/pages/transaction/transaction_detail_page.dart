import 'package:flutter/material.dart';
import '../../../storage/database_helper.dart';
import '../../../models/transaction_model.dart';
import '../../../utils/formatters.dart';
import 'edit_transaction_page.dart';
import '../../../utils/notifications.dart';

class TransactionDetailPage extends StatefulWidget {
  final int transactionId;
  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  Future<Map<String, dynamic>?>? _detailFuture;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    setState(() {
      _detailFuture =
          DatabaseHelper().getTransactionDetail(widget.transactionId);
    });
  }

  Future<void> _cancelTransaction(Map<String, dynamic> tr) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Sewa'),
        content: const Text('Apakah Anda yakin ingin membatalkan penyewaan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya')),
        ],
      ),
    );

    if (confirmed == true) {
      final updatedTr = TransactionModel.fromMap(tr).toMap();
      updatedTr['status'] = 'dibatalkan';
      
      await DatabaseHelper().updateTransaction(TransactionModel.fromMap(updatedTr));
      if (mounted) {
        showAppNotification(context, 'Penyewaan berhasil dibatalkan.', type: NotificationType.success);
      }
      _loadDetail(); // Refresh halaman
    }
  }

  void _navigateToEdit(Map<String, dynamic> tr) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => EditTransactionPage(
              initialData: TransactionModel.fromMap(tr))),
    );
    _loadDetail(); // Refresh data setelah kembali dari edit
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Penyewaan')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Data transaksi tidak ditemukan.'));
          }

          final tr = snapshot.data!;
          final status = tr['status'] as String;
          final isAktif = status == 'aktif';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Detail Mobil
                _buildInfoCard(context, 'Detail Mobil', [
                  _buildDetailRow('Nama Mobil', tr['namaMobil']),
                  _buildDetailRow('Jenis Mobil', tr['jenisMobil']),
                ]),
                const SizedBox(height: 16),
                
                // Detail Penyewa
                _buildInfoCard(context, 'Detail Penyewaan', [
                  _buildDetailRow('Nama Penyewa', tr['namaPenyewa']),
                  _buildDetailRow('Lama Sewa', '${tr['lamaSewa']} Hari'),
                  _buildDetailRow('Tanggal Mulai', formatDate(tr['tanggalMulai'])),
                ]),
                const SizedBox(height: 16),

                // Biaya & Status
                _buildInfoCard(context, 'Biaya dan Status', [
                  _buildDetailRow('Total Biaya', formatRupiah(tr['totalHarga']), isBold: true, color: Colors.green.shade700),
                  _buildDetailRow('Status', status.toUpperCase(), isBold: true, color: status == 'dibatalkan' ? Colors.red : (status == 'aktif' ? Colors.blue.shade700 : Colors.grey)),
                ]),
                const SizedBox(height: 30),

                // Tombol Aksi
                if (isAktif)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _navigateToEdit(tr),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Sewa'),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Theme.of(context).colorScheme.secondary),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _cancelTransaction(tr),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Batalkan Sewa'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali ke Riwayat'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}