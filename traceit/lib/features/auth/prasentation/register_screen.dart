import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Контроллеры для захвата текста из полей
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedPvz = "Бишкек, Склад №1"; // Значение по умолчанию

  Future<void> _signUp() async {
    try {
      // 1. Создаем пользователя в Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "${_phoneController.text}@traseit.com", // Твой план: номер как почта
        password: _passwordController.text,
      );

      // 2. Сохраняем данные в Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'pvz': _selectedPvz,
        'userCode': "TR-${userCredential.user!.uid.substring(0, 5).toUpperCase()}",
      });

      print("УРА! Пользователь создан в консоли!");
    } catch (e) {
      print("Ошибка: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Регистрация в Traselt")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Имя")),
            TextField(controller: _phoneController, decoration: InputDecoration(labelText: "Номер телефона")),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Пароль"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _signUp, child: Text("Зарегистрироваться")),
          ],
        ),
      ),
    );
  }
}