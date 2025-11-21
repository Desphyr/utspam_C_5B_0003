import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../utils/formatters.dart';

class CarCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback onRentPressed;

  const CarCard({super.key, required this.car, required this.onRentPressed});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    
    final double imageHeight = screenHeight < 700 ? 130 : 160;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/${car.gambar}',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.broken_image, size: 40)),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              car.namaMobil,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              car.jenisMobil,
              style: const TextStyle(color: Colors.grey),
            ),

            const Spacer(),

            Text(
              '${formatRupiah(car.hargaSewa)} / hari',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRentPressed,
                child: const Text('Sewa'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
