import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';
import 'package:traceit/features/pvz/data/pvz_service.dart';
import 'package:traceit/features/pvz/domain/pvz_model.dart';

class AdminWhatsappTemplatesScreen extends StatefulWidget {
  const AdminWhatsappTemplatesScreen({super.key});

  @override
  State<AdminWhatsappTemplatesScreen> createState() =>
      _AdminWhatsappTemplatesScreenState();
}

class _AdminWhatsappTemplatesScreenState
    extends State<AdminWhatsappTemplatesScreen> {
  final _templateCtrl = TextEditingController();
  String? _selectedPvzId;
  final _pvzService = PvzService();

  @override
  void dispose() {
    _templateCtrl.dispose();
    super.dispose();
  }

  void _onPvzSelected(PvzModel? p) {
    setState(() {
      _selectedPvzId = p?.id;
      _templateCtrl.text = p?.whatsappTemplate ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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
          appBar: AppBar(title: const Text('WhatsApp шаблоны')),
          body: StreamBuilder<List<PvzModel>>(
            stream: _pvzService.watchPvzList(),
            builder: (context, snap) {
              final list = snap.data ?? [];
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Выберите ПВЗ и отредактируйте текст для WhatsApp '
                    '(адрес самовывоза, график, реквизиты).',
                  ),
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'ПВЗ',
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedPvzId != null &&
                                list.any((p) => p.id == _selectedPvzId)
                            ? _selectedPvzId
                            : null,
                        hint: const Text('Выберите ПВЗ'),
                        items: list
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.displayLabel),
                              ),
                            )
                            .toList(),
                        onChanged: (id) {
                          if (id == null) return;
                          PvzModel? p;
                          for (final x in list) {
                            if (x.id == id) {
                              p = x;
                              break;
                            }
                          }
                          _onPvzSelected(p);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _templateCtrl,
                    minLines: 8,
                    maxLines: 16,
                    decoration: const InputDecoration(
                      labelText: 'Шаблон сообщения',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _selectedPvzId == null
                        ? null
                        : () async {
                            await _pvzService.updateWhatsappTemplate(
                              pvzId: _selectedPvzId!,
                              template: _templateCtrl.text,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Сохранено')),
                              );
                            }
                          },
                    child: const Text('Сохранить шаблон'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
