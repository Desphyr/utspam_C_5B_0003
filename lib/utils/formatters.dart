import 'package:intl/intl.dart';

String formatRupiah(int amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

String formatDate(String dateString) {
  final date = DateTime.parse(dateString);
  return DateFormat('d MMMM yyyy', 'id_ID').format(date);
}