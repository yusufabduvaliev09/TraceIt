import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';
import 'package:traceit/features/cargo/data/cargo_service.dart';
import 'package:traceit/features/cargo/domain/client_model.dart';
import 'package:traceit/features/cargo/domain/cargo_model.dart';
import 'package:traceit/features/cargo/domain/cargo_status.dart';
import 'package:traceit/features/pvz/data/pvz_service.dart';
import 'package:traceit/features/pvz/domain/pvz_model.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final CargoService _cargoService = CargoService();
  final PvzService _pvzService = PvzService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _trackController = TextEditingController();
  final _weightController = TextEditingController();
  final _notificationBodyController = TextEditingController();
  String? _selectedClientUid;
  final Set<String> _selectedForBulk = {};

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _trackController.dispose();
    _weightController.dispose();
    _notificationBodyController.dispose();
    super.dispose();
  }

  Future<void> _addCargo(List<ClientModel> clients) async {
    final weight = double.tryParse(_weightController.text) ?? 0;
    ClientModel? selectedClient;
    for (final client in clients) {
      if (client.uid == _selectedClientUid) {
        selectedClient = client;
        break;
      }
    }
    if (selectedClient == null ||
        _titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _trackController.text.isEmpty ||
        weight <= 0) {
      return;
    }
    await _cargoService.addCargo(
      ownerUid: selectedClient.uid,
      ownerName: selectedClient.name,
      ownerCustomerId: selectedClient.customerId,
      title: _titleController.text,
      description: _descriptionController.text,
      trackCode: _trackController.text,
      weight: weight,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cargo added')),
    );
  }

  Future<void> _sendNotificationAll(String adminUid) async {
    if (_notificationBodyController.text.isEmpty) {
      return;
    }
    await _cargoService.sendBroadcastNotification(
      message: _notificationBodyController.text,
      createdBy: adminUid,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification sent')),
    );
  }

  Future<void> _applyBulkTransitToWarehouse() async {
    if (_selectedForBulk.isEmpty) return;
    await _cargoService.bulkUpdateCargoStatus(
      cargoIds: _selectedForBulk.toList(),
      fromStatus: CargoStatusKeys.transit,
      toStatus: CargoStatusKeys.warehouseChina,
    );
    if (!mounted) return;
    setState(_selectedForBulk.clear);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bulk status updated: transit -> warehouse')),
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
          return StreamBuilder<List<PvzModel>>(
            stream: _pvzService.watchPvzList(),
            builder: (context, pvzSnapshot) {
              final pvzList = pvzSnapshot.data ?? [];
              return StreamBuilder<List<ClientModel>>(
                stream: _cargoService.getAllUsers(),
                builder: (context, userSnapshot) {
                  final users = userSnapshot.data ?? [];
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const ListTile(
                              leading: Icon(Icons.tune),
                              title: Text('Настройки администратора'),
                              subtitle: Text(
                                'ПВЗ, шаблон адреса Китая, WhatsApp',
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.storefront_outlined),
                              title: const Text('Управление ПВЗ'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () =>
                                  context.push('/admin/settings/pvz'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.place_outlined),
                              title: const Text('Шаблон адреса (Китай)'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () =>
                                  context.push('/admin/settings/china-template'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.chat_outlined),
                              title: const Text('WhatsApp шаблоны'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push(
                                '/admin/settings/whatsapp',
                              ),
                            ),
                          ],
                        ),
                      ),
                      ExpansionTile(
                    initiallyExpanded: true,
                    title: const Text('Cargo Management'),
                    childrenPadding: const EdgeInsets.all(12),
                    children: [
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Клиент',
                          border: OutlineInputBorder(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedClientUid,
                            hint: const Text('Выберите клиента'),
                            items: users
                                .map(
                                  (u) => DropdownMenuItem(
                                    value: u.uid,
                                    child: Text('${u.name} (${u.customerId})'),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedClientUid = value),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _trackController,
                        decoration: const InputDecoration(labelText: 'Трек-номер'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Название'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Описание'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Вес (kg)'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _addCargo(users),
                        child: const Text('Добавить посылку'),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<List<CargoModel>>(
                        stream: _cargoService.getAllCargo(),
                        builder: (context, snapshot) {
                          final cargoList = snapshot.data ?? [];
                          final transit = cargoList.where((c) => c.status == 'transit').toList();
                          if (transit.isEmpty) {
                            return const Text('Нет посылок в статусе "В пути"');
                          }
                          return Column(
                            children: [
                              ...transit.map(
                                (cargo) => CheckboxListTile(
                                  value: _selectedForBulk.contains(cargo.id),
                                  title: Text('${cargo.trackCode} · ${cargo.title}'),
                                  subtitle: Text('Статус: ${cargo.status}'),
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _selectedForBulk.add(cargo.id);
                                      } else {
                                        _selectedForBulk.remove(cargo.id);
                                      }
                                    });
                                  },
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _applyBulkTransitToWarehouse,
                                child: const Text('Массово: В пути -> На складе в Китае'),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                      ExpansionTile(
                    title: const Text('Client Control'),
                    childrenPadding: const EdgeInsets.all(12),
                    children: users
                        .map(
                          (client) {
                            String? pvzValue = client.pvzDocId;
                            if (pvzValue != null &&
                                !pvzList.any((p) => p.id == pvzValue)) {
                              pvzValue = null;
                            }
                            return Card(
                              child: ListTile(
                                title: Text(
                                    '${client.name} · ${client.customerId}'),
                                subtitle: Text(
                                    '${client.phone}\nПВЗ: ${client.pvz}'),
                                isThreeLine: true,
                                trailing: SizedBox(
                                  width: 160,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Switch(
                                        value: client.isBlocked,
                                        onChanged: (value) => _cargoService
                                            .setUserBlocked(
                                          uid: client.uid,
                                          isBlocked: value,
                                        ),
                                      ),
                                      if (pvzList.isNotEmpty)
                                        DropdownButton<String>(
                                          value: pvzValue,
                                          hint: const Text('ПВЗ'),
                                          isExpanded: true,
                                          items: pvzList
                                              .map(
                                                (p) => DropdownMenuItem(
                                                  value: p.id,
                                                  child: Text(
                                                    p.displayLabel,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: pvzList.isEmpty
                                              ? null
                                              : (id) {
                                                  if (id == null) return;
                                                  _cargoService
                                                      .updateUserPvzFromDoc(
                                                    uid: client.uid,
                                                    pvzDocId: id,
                                                  );
                                                },
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                        .toList(),
                  ),
                      ExpansionTile(
                    title: const Text('Notifications'),
                    childrenPadding: const EdgeInsets.all(12),
                    children: [
                      TextField(
                        controller: _notificationBodyController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Текст рассылки',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _sendNotificationAll(
                          authProvider.currentUser?.uid ?? 'unknown_admin',
                        ),
                        child: const Text('Отправить всем'),
                      ),
                    ],
                  ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
