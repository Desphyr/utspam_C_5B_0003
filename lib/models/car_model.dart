class CarModel {
  final int? id;
  final String namaMobil;
  final String jenisMobil;
  final int hargaSewa; 
  final String gambar; 

  CarModel({
    this.id,
    required this.namaMobil,
    required this.jenisMobil,
    required this.hargaSewa,
    required this.gambar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaMobil': namaMobil,
      'jenisMobil': jenisMobil,
      'hargaSewa': hargaSewa,
      'gambar': gambar,
    };
  }

  factory CarModel.fromMap(Map<String, dynamic> map) {
    return CarModel(
      id: map['id'],
      namaMobil: map['namaMobil'],
      jenisMobil: map['jenisMobil'],
      hargaSewa: map['hargaSewa'],
      gambar: map['gambar'],
    );
  }
}