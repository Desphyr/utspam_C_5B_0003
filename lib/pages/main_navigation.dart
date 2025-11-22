import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home/home_page.dart';
import 'car/car_list_page.dart';
import 'transaction/transaction_history_page.dart';
import 'profile/profile_page.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('currentUserId');
    });
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const CarListPage();
      case 2:
        if (_userId == null) {
          return const Center(child: Text('Silakan login untuk melihat riwayat.'));
        }
        return TransactionHistoryPage(userId: _userId!);
      case 3:
        if (_userId == null) {
          return const Center(child: Text('Silakan login untuk melihat profil.'));
        }
        return ProfilePage(userId: _userId!);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = List.generate(4, (i) => _buildPage(i));

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Sewa Mobil'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
