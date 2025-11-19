import 'package:flutter/material.dart';
import '../../storage/database_helper.dart';
import 'transaction_detail_page.dart';
import '../../utils/formatters.dart';

class TransactionHistoryPage extends StatefulWidget {
  final int userId;
  const TransactionHistoryPage({super.key, required this.userId});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  Future<List<Map<String, dynamic>>>? _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      _transactionsFuture = DatabaseHelper().getAllTransactions(widget.userId);
    });
  }

  void _navigateToDetail(int transactionId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>
              TransactionDetailPage(transactionId: transactionId)),
    );
    // Refresh data setelah kembali dari halaman detail (untuk melihat perubahan status)
    _loadTransactions(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Penyewaan')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Anda belum memiliki riwayat sewa.'));
          }

          final transactions = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tr = transactions[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  onTap: () => _navigateToDetail(tr['id']),
                  leading: const Icon(Icons.receipt, color: Colors.blue),
                  title: Text(tr['namaMobil']),
                  subtitle: Text('Tgl Mulai: ${formatDate(tr['tanggalMulai'])} | ${tr['lamaSewa']} Hari'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatRupiah(tr['totalHarga']), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      Text(tr['status'].toString().toUpperCase(), style: TextStyle(color: tr['status'] == 'dibatalkan' ? Colors.red : (tr['status'] == 'aktif' ? Colors.blue : Colors.grey))),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}