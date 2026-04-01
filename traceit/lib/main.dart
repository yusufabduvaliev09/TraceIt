import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Заменяем пустой вызов на детальный
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBu48EPBKzXCE8s9kny8U2AQJtV5jPl_t0', 
      appId: '1:98494377430:ios:99bfc786fcf5e605b30877', 
      messagingSenderId: '98494377430', 
      projectId: 'traseit-939b6', // Твой ID проекта
      storageBucket: 'traseit-939b6.appspot.com',
      iosBundleId: 'com.traceit', // Проверь этот ID в Xcode
    ),
  ); 
  
  runApp(const CargoApp());
}

class CargoApp extends StatelessWidget {
  const CargoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TraceIt Cargo',
      theme: ThemeData.dark(), // Тёмная тема
      home: const TestScreen(), // Пока оставляем этот экран для теста
    );
  }
}

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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Сеньор одобряет. Идем дальше?"),
          ],
        ),
      ),
    );
  }
}