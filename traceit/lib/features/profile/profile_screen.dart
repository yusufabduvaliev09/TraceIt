import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard (nusxa olish) uchun kerak
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';

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
    final authProvider = context.watch<AuthProvider>();
    const fallbackCode = "TR-0000";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой Профиль'), // "Mening profilim"
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Ekran chetidan 16 birlik joy tashlaydi
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: authProvider.userDocumentStream(),
          builder: (context, snapshot) {
            final userCode = (snapshot.data?['customerId'] ?? fallbackCode).toString();
            final chinaAddress =
                "Guangzhou, Baiyun District, Warehouse №7, Code: $userCode";
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Elementlarni chapdan tekislaydi
              children: [
                Container(
                  width: double.infinity, // Butun ekran kengligi bo'yicha
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Column(
                    children: [
                      const Text('Ваш уникальный код:',
                          style: TextStyle(fontSize: 16)),
                      Text(
                        userCode,
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Адрес склада в Китае:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    chinaAddress,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(context, chinaAddress),
                    icon: const Icon(Icons.copy),
                    label: const Text('Копировать адрес для Pinduoduo'),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      await authProvider.logout();
                      if (!context.mounted) return;
                      context.go('/auth');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}