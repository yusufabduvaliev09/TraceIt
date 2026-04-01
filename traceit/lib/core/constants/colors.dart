import 'package:flutter/material.dart'; // Flutter'ning tayyor UI elementlarini ishlatish uchun kerak

class AppColors { // Ranglarni bitta guruhga (klassga) yig'amiz
  
  // Static - bu rangni ishlatish uchun klassdan yangi nusxa olish shart emasligini bildiradi
  // const - bu rang ilova davomida hech qachon o'zgarmasligini bildiradi
  // Color(0xFF...) - rangning HEX kodi. 'FF' - shaffoflik (100% ko'rinadi)
  
  static const Color primary = Color(0xFF6200EE); // Asosiy rang (masalan, tugmalar uchun)
  static const Color background = Color(0xFF121212); // To'q mavzu uchun fon rangi
  static const Color surface = Color(0xFF1E1E1E); // Kartochkalar va panellar rangi
  static const Color textMain = Color(0xFFFFFFFF); // Asosiy oq matn
  static const Color textSecondary = Color(0xB3FFFFFF); // Biroz xiralashgan matn (70% ko'rinishda)
  static const Color accent = Color(0xFF03DAC6); // Diqqatni tortuvchi elementlar rangi
  static const Color error = Color(0xFFCF6679); // Xatolik rangi
}