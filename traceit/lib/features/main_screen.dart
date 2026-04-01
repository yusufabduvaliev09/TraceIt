import 'package:flutter/material.dart';
// BU YERDA IMPORTLAR BO'LISHI KERAK:
import '../cargo/data/cargo_service.dart';
import '../cargo/domain/cargo_model.dart';
import '../../core/widgets/cargo_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 1. _screens ro'yxatini o'zgartiramiz. 
  // Endi har bir element shunchaki Text emas, balki StreamBuilder bo'ladi.
  final List<Widget> _screens = [
    // 0-vkladka: Kutilmoqda (В ожидании)
    _buildCargoList('pending'), 
    
    // 1-vkladka: Yo'lda (В пути)
    _buildCargoList('transit'), 
    
    // 2-vkladka: Omborda (На складе)
    _buildCargoList('warehouse'), 
    
    // 3-vkladka: Topshirildi (Получено)
    _buildCargoList('delivered'), 
  ];

  // 2. Bu yerda biz kodimiz takrorlanmasligi uchun bitta umumiy "qolip" (funksiya) yaratdik.
  // U 'status'ga qarab bizga kerakli ro'yxatni yasab beradi.
  static Widget _buildCargoList(String status) {
    return StreamBuilder(
      // stream - CargoService dan ma'lumotni oqimini oladi.
      // "USER_ID_TEST" o'rniga keyinchalik haqiqiy foydalanuvchi ID si keladi.
      stream: CargoService().getMyCargo("USER_ID_TEST"), 
      builder: (context, snapshot) {
        // snapshot.connectionState - bu ulanish holati.
        // Agar hali ma'lumot kelayotgan bo'lsa (waiting), aylanuvchi doira chiqadi.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Agar xatolik bo'lsa yoki ma'lumot bo'sh bo'lsa.
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Посылок пока нет'));
        }

        // .where - kelgan hamma posilkalar ichidan faqat biz so'ragan statusga mosini oladi.
        final filteredList = snapshot.data!
            .where((cargo) => cargo.status == status)
            .toList();

        // Agar filtrdan keyin ro'yxat bo'sh bo'lsa.
        if (filteredList.isEmpty) {
          return const Center(child: Text('В этой категории пусто'));
        }

        // ListView.builder - posilkalarni chiroyli ro'yxat qilib chiqaradi.
        return ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            // Har bir posilka uchun biz yaratgan CargoCard vidjetini ishlatadi.
            return CargoCard(cargo: filteredList[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 3. body qismi biz tepada yaratgan ro'yxatdan kerakli sahifani oladi.
      body: _screens[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.hourglass_bottom), label: 'Ожидание'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'В пути'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Склад'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Получено'),
        ],
      ),
    );
  }
}