import 'package:flutter/material.dart';
import 'colors.dart'; // Yuqorida yaratgan ranglarimizni bu yerga chaqiramiz

class AppTheme {
  // darkTheme nomli o'zgaruvchi yaratamiz
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark, // Ilovaga bu 'To'q mavzu' ekanini bildiradi
    scaffoldBackgroundColor: AppColors.background, // Ilova ekranlarining foni
    
    // ColorScheme - bu ilovadagi tizimli ranglar xaritasi
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    // Matnlar uslubi (Text Theme)
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32, 
        fontWeight: FontWeight.bold, 
        color: AppColors.textMain,
      ),
      bodyLarge: TextStyle(
        fontSize: 16, 
        color: AppColors.textMain,
      ),
    ),

    // Tugmalarning umumiy dizayni
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // Tugma rangi
        foregroundColor: Colors.white, // Tugma ichidagi yozuv rangi
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Tugma chetini yumaloqlash
        ),
      ),
    ),
  );
}