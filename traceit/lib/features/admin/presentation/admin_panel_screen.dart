import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';
import 'package:traceit/features/cargo/data/cargo_service.dart';
import 'package:traceit/features/cargo/domain/cargo_model.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final CargoService _cargoService = CargoService();
  final _ownerUidController = TextEditingController();
  final _titleController = TextEditingController();
  final _trackController = TextEditingController();
  final _weightController = TextEditingController();
  final _notificationTitleController = TextEditingController();
  final _notificationBodyController = TextEditingController();

  @override
  void dispose() {
    _ownerUidController.dispose();
    _titleController.dispose();
    _trackController.dispose();
    _weightController.dispose();
    _notificationTitleController.dispose();
    _notificationBodyController.dispose();
    super.dispose();
  }

  Future<void> _addCargo() async {
    final weight = double.tryParse(_weightController.text) ?? 0;
    if (_ownerUidController.text.isEmpty ||
        _titleController.text.isEmpty ||
        _trackController.text.isEmpty ||
        weight <= 0) {
      return;
    }
    await _cargoService.addCargo(
      ownerUid: _ownerUidController.text,
      title: _titleController.text,
      trackCode: _trackController.text,
      weight: weight,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cargo added')),
    );
  }

  Future<void> _sendNotification() async {
    if (_notificationTitleController.text.isEmpty ||
        _notificationBodyController.text.isEmpty) {
      return;
    }
    await _cargoService.sendNotification(
      title: _notificationTitleController.text,
      body: _notificationBodyController.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification sent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: authProvider.userDocumentStream(),
        builder: (context, roleSnapshot) {
          final role = (roleSnapshot.data?['role'] ?? 'user').toString();
          if (role != 'admin' && role != 'dev') {
            return const Center(
              child: Text('You do not have access to Admin Panel'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Add Cargo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextField(
                controller: _ownerUidController,
                decoration: const InputDecoration(labelText: 'Owner User UID'),
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Cargo title'),
              ),
              TextField(
                controller: _trackController,
                decoration: const InputDecoration(labelText: 'Track code'),
              ),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _addCargo,
                child: const Text('Add Cargo'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Update Cargo Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              StreamBuilder<List<CargoModel>>(
                stream: _cargoService.getAllCargo(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    );
                  }
                  final list = snapshot.data!;
                  if (list.isEmpty) return const Text('No cargo found');
                  return Column(
                    children: list
                        .map(
                          (cargo) => Card(
                            child: ListTile(
                              title: Text('${cargo.title} (${cargo.trackCode})'),
                              subtitle: Text('Current: ${cargo.status}'),
                              trailing: DropdownButton<String>(
                                value: cargo.status,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'pending', child: Text('Pending')),
                                  DropdownMenuItem(
                                      value: 'transit', child: Text('In Transit')),
                                  DropdownMenuItem(
                                      value: 'warehouse',
                                      child: Text('In Warehouse')),
                                  DropdownMenuItem(
                                      value: 'delivered',
                                      child: Text('Delivered/Sold')),
                                ],
                                onChanged: (value) async {
                                  if (value == null) return;
                                  await _cargoService.updateCargoStatus(
                                    cargoId: cargo.id,
                                    status: value,
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Send Notification',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextField(
                controller: _notificationTitleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _notificationBodyController,
                decoration: const InputDecoration(labelText: 'Body'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _sendNotification,
                child: const Text('Send'),
              ),
            ],
          );
        },
      ),
    );
  }
}
