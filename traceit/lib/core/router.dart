import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// GoRouter - bu ilovadagi barcha yo'llarni boshqaruvchi klass
final AppRouter = GoRouter(
  initialLocation: '/', // Ilova ochilganda birinchi bo'lib ko'rsatiladigan manzil
  routes: [
    GoRoute(
      path: '/', // Bu 'Uy' (Home) manzilini anglatadi
      builder: (context, state) => const MainScreen(), // Manzilga mos keluvchi ekran
    ),
  ],
);