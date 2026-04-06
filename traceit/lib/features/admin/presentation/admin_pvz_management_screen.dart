import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';
import 'package:traceit/features/pvz/data/pvz_service.dart';
import 'package:traceit/features/pvz/domain/pvz_model.dart';

class AdminPvzManagementScreen extends StatelessWidget {
  const AdminPvzManagementScreen({super.key});

  Future<void> _showPvzDialog(
    BuildContext context, {
    PvzModel? existing,
  }) async {
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final addrCtrl = TextEditingController(text: existing?.address ?? '');
    final service = PvzService();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(existing == null ? 'Новый ПВЗ' : 'Изменить ПВЗ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Код (YX, DZ)'),
                  textCapitalization: TextCapitalization.characters,
                ),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                TextField(
                  controller: addrCtrl,
                  decoration: const InputDecoration(labelText: 'Адрес'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () async {
                if (codeCtrl.text.trim().isEmpty ||
                    nameCtrl.text.trim().isEmpty) {
                  return;
                }
                if (existing == null) {
                  await service.addPvz(
                    code: codeCtrl.text,
                    name: nameCtrl.text,
                    address: addrCtrl.text,
                  );
                } else {
                  await service.updatePvz(
                    id: existing.id,
                    code: codeCtrl.text,
                    name: nameCtrl.text,
                    address: addrCtrl.text,
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final service = PvzService();

    return StreamBuilder<Map<String, dynamic>?>(
      stream: auth.userDocumentStream(),
      builder: (context, roleSnap) {
        final role = (roleSnap.data?['role'] ?? 'user').toString();
        if (role != 'admin' && role != 'dev') {
          return const Scaffold(
            body: Center(child: Text('Нет доступа')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Управление ПВЗ')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showPvzDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Добавить ПВЗ'),
          ),
          body: StreamBuilder<List<PvzModel>>(
            stream: service.watchPvzList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return const Center(
                  child: Text('Нет ПВЗ. Добавьте первый пункт.'),
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('Код')),
                          DataColumn(label: Text('Название')),
                          DataColumn(label: Text('Адрес')),
                          DataColumn(label: Text('')),
                        ],
                        rows: list
                            .map(
                              (p) => DataRow(
                                cells: [
                                  DataCell(Text(p.code)),
                                  DataCell(Text(p.name)),
                                  DataCell(
                                    SizedBox(
                                      width: 220,
                                      child: Text(
                                        p.address,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    TextButton(
                                      onPressed: () => _showPvzDialog(
                                        context,
                                        existing: p,
                                      ),
                                      child: const Text('Изменить'),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
