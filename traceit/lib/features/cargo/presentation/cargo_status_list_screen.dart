import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';
import 'package:traceit/features/cargo/data/cargo_service.dart';
import 'package:traceit/features/cargo/domain/cargo_model.dart';
import 'package:traceit/features/cargo/domain/cargo_status.dart';

class CargoStatusListScreen extends StatelessWidget {
  const CargoStatusListScreen({super.key, required this.statusKey});

  final String statusKey;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final normalized = CargoStatusKeys.homeOrder.contains(statusKey)
        ? statusKey
        : CargoStatusKeys.normalize(statusKey);

    return Scaffold(
      appBar: AppBar(
        title: Text(CargoStatusKeys.labelRu(normalized)),
      ),
      body: StreamBuilder<List<CargoModel>>(
        stream: CargoService().getMyCargo(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data ?? [];
          final filtered =
              list.where((c) => c.status == normalized).toList();
          if (filtered.isEmpty) {
            return Center(
              child: Text(
                'Нет посылок в статусе «${CargoStatusKeys.labelRu(normalized)}»',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final c = filtered[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(
                    c.trackCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: c.description.isNotEmpty
                      ? Text(c.description)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
