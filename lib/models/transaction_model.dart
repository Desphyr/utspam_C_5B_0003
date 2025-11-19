class TransactionModel {
  final int? id;
  final int userId;
  final int carId;
  final String namaPenyewa;
  final int lamaSewa; 
  final String tanggalMulai; 
  final int totalHarga;
  final String status; // 'aktif', 'selesai', 'dibatalkan'

  TransactionModel({
    this.id,
    required this.userId,
    required this.carId,
    required this.namaPenyewa,
    required this.lamaSewa,
    required this.tanggalMulai,
    required this.totalHarga,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'carId': carId,
      'namaPenyewa': namaPenyewa,
      'lamaSewa': lamaSewa,
      'tanggalMulai': tanggalMulai,
      'totalHarga': totalHarga,
      'status': status,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      userId: map['userId'],
      carId: map['carId'],
      namaPenyewa: map['namaPenyewa'],
      lamaSewa: map['lamaSewa'],
      tanggalMulai: map['tanggalMulai'],
      totalHarga: map['totalHarga'],
      status: map['status'],
    );
  }
}