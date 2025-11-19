import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../utils/formatters.dart';

class CarCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback onRentPressed;

  const CarCard({super.key, required this.car, required this.onRentPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120, 
              width: double.infinity,
              child: Image.asset(
                'assets/images/${car.gambar}',
                fit: BoxFit.cover, 
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              car.namaMobil,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(car.jenisMobil, style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            Text(
              '${formatRupiah(car.hargaSewa)} / hari',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRentPressed,
                child: const Text('Sewa'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
