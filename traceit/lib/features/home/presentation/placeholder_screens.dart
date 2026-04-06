import 'package:flutter/material.dart';

class MapRoutePlaceholderScreen extends StatelessWidget {
  const MapRoutePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Грузы на карте')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Маршрут Гуанчжоу — Бишкек\n(карта будет подключена позже)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class UnknownParcelsPlaceholderScreen extends StatelessWidget {
  const UnknownParcelsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Неизвестные посылки')),
      body: const Center(
        child: Text('Раздел в разработке'),
      ),
    );
  }
}

class InstructionPlaceholderScreen extends StatelessWidget {
  const InstructionPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Инструкция')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Здесь будет инструкция по оформлению и получению посылок ABU Cargo.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
