import 'package:flutter/material.dart';
import 'package:traceit/features/cargo/domain/cargo_model.dart';
class CargoCard extends StatelessWidget {
  final CargoModel cargo;
  const CargoCard({super.key, required this.cargo});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(Icons.inventory, color: Colors.blueAccent),
        title: Text(cargo.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Трек: ${cargo.trackCode}"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${cargo.weight} kg", style: const TextStyle(color: Colors.green)),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}