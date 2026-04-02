import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traceit/core/router.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';

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
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'TraceIt Cargo',
        theme: ThemeData.dark(),
        routerConfig: appRouter,
      ),
    );
  }
}