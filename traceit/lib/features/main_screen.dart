import 'package:flutter/material.dart';

// StatefulWidget - bu ekran ichidagi ma'lumotlar (masalan, bosilgan tugma) 
// o'zgarishi mumkin bo'lgan vidjet turi.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // _selectedIndex - bu butun son (int). 
  // Pastki menyuda nechanchi tugma bosilganini eslab qoladi. 0 - birinchisi.
  int _selectedIndex = 0;

  // _screens - bu vidjetlar ro'yxati (List). 
  // Har bir menyu tugmasiga bosilganda chiqadigan alohida sahifalar.
  final List<Widget> _screens = [
    const Center(child: Text('В ожидании')), // 0-indeks: "Kutilmoqda"
    const Center(child: Text('В пути')),      // 1-indeks: "Yo'lda"
    const Center(child: Text('На складе')),   // 2-indeks: "Omborda"
    const Center(child: Text('Получено')),    // 3-indeks: "Topshirildi"
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold - bu standart ekran qurilmasi (shabloni).
    return Scaffold(
      // body - ekranning asosiy qismi. 
      // Biz ro'yxatdan hozirgi tanlangan indeksga mos sahifani olib ko'rsatamiz.
      body: _screens[_selectedIndex], 
      
      // bottomNavigationBar - ekranning eng pastki qismidagi navigatsiya paneli.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Hozir qaysi tugma tanlangani (yoniq turishi).
        
        // onTap - foydalanuvchi tugmani bosganida ishlaydigan funksiya.
        // 'index' - bu bosilgan tugmaning tartib raqami (0, 1, 2 yoki 3).
        onTap: (index) {
          // setState - Flutter'ga "Ma'lumot o'zgardi, ekranni yangidan chiz!" degan buyruq.
          setState(() {
            _selectedIndex = index; // Yangi raqamni saqlaymiz.
          });
        },
        
        // type: Fixed - menyu elementlari joyida qimirlamay turishi uchun.
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent, // Tanlangan tugmaning rangi.
        unselectedItemColor: Colors.grey,     // Tanlanmagan tugmalarning rangi.
        
        // items - menyudagi tugmalarning o'zi. Kamida 2 ta bo'lishi shart.
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_bottom), 
            label: 'Ожидание', // "Kutilmoqda" matni ruscha
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping), 
            label: 'В пути', // "Yo'lda" matni ruscha
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2), 
            label: 'Склад', // "Ombor" matni ruscha
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle), 
            label: 'Получено', // "Topshirildi" matni ruscha
          ),
        ],
      ),
    );
  }
}