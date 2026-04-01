import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard (nusxa olish) uchun kerak

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Nusxa olish funksiyasi
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text)); // Matnni telefon xotirasiga nusxalaydi
    
    // Pastdan kichkina xabarcha chiqaradi (Snackbox)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Адрес скопирован!')), // "Manzil nusxalandi"
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bu ma'lumotlar keyinchalik Firebase'dan keladi, hozircha qo'lda yozamiz
    const String userCode = "KGZ-8821"; 
    const String chinaAddress = "Guangzhou, Baiyun District, Warehouse №7, Code: $userCode";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой Профиль'), // "Mening profilim"
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Ekran chetidan 16 birlik joy tashlaydi
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Elementlarni chapdan tekislaydi
          children: [
            // Foydalanuvchi kodi kartochkasi
            Container(
              width: double.infinity, // Butun ekran kengligi bo'yicha
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1), // Orqa foni biroz havorang
                borderRadius: BorderRadius.circular(15), // Burchaklari yumaloq
                border: Border.all(color: Colors.blueAccent), // Chetki chizig'i
              ),
              child: Column(
                children: [
                  const Text('Ваш уникальный код:', style: TextStyle(fontSize: 16)),
                  Text(
                    userCode, 
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30), // Ikkita vidjet orasida 30 birlik bo'shliq

            const Text(
              'Адрес склада в Китае:', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Manzil turadigan joy
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[900], // To'q kulrang fon
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chinaAddress,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),

            const SizedBox(height: 20),

            // Nusxa olish tugmasi
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _copyToClipboard(context, chinaAddress), // Bosilganda funksiya ishlaydi
                icon: const Icon(Icons.copy), // Nusxa olish belgisi
                label: const Text('Копировать адрес для Pinduoduo'), // Tugma matni
              ),
            ),
          ],
        ),
      ),
    );
  }
}