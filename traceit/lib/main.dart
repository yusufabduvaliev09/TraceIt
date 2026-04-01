import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  // Это обязательные строки для инициализации Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  
  runApp(const CargoApp());
}

class CargoApp extends StatelessWidget {
  const CargoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TraceIt Cargo',
      // Наша тема (пока стандартная темная)
      theme: ThemeData.dark(), 
      home: const TestScreen(),
    );
  }
}

// Временный экран, чтобы проверить, что всё работает
class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              "Firebase подключен успешно!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Теперь можно делать регистрацию"),
          ],
        ),
      ),
    );
  }
}