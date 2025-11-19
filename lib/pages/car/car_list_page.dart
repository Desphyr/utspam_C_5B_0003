import 'package:flutter/material.dart';
import '../../../models/car_model.dart';
import '../../../storage/database_helper.dart';
import '../../../widgets/car_card.dart';
import 'car_rent_form_page.dart';

class CarListPage extends StatefulWidget {
  const CarListPage({super.key});

  @override
  State<CarListPage> createState() => _CarListPageState();
}

class _CarListPageState extends State<CarListPage> {
  Future<List<CarModel>>? _carsFuture;

  @override
  void initState() {
    super.initState();
    _carsFuture = DatabaseHelper().getAllCars();
  }

  void _navigateToRentForm(CarModel car) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => CarRentFormPage(
                car: car,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Mobil Tersedia')),
      body: FutureBuilder<List<CarModel>>(
        future: _carsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada mobil tersedia.'));
          }

          final cars = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65, 
            ),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return CarCard(
                car: car,
                onRentPressed: () => _navigateToRentForm(car),
              );
            },
          );
        },
      ),
    );
  }
}