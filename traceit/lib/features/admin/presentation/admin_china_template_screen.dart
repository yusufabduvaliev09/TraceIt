import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traceit/core/utils/china_address_template.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';
import 'package:traceit/features/cargo/data/cargo_service.dart';

class AdminChinaTemplateScreen extends StatefulWidget {
  const AdminChinaTemplateScreen({super.key});

  @override
  State<AdminChinaTemplateScreen> createState() =>
      _AdminChinaTemplateScreenState();
}

class _AdminChinaTemplateScreenState extends State<AdminChinaTemplateScreen> {
  final _controller = TextEditingController();
  final _cargoService = CargoService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = (await _cargoService.readChinaAddressTemplateOnce()).trim();
    if (mounted) {
      setState(() {
        _controller.text = t;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          appBar: AppBar(title: const Text('Шаблон адреса (Китай)')),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Используйте плейсхолдер (ID) или {ID} — он будет заменён на ID клиента (например YX1).',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      minLines: 4,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'Шаблон адреса склада в Китае',
                        alignLabelWithHint: true,
                        hintText: '御玺(ID) 15727306315 浙江省金华市...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        await _cargoService
                            .saveChinaAddressTemplate(_controller.text);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Сохранено')),
                          );
                        }
                      },
                      child: const Text('Сохранить шаблон'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Пример для клиента YX1:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          applyChinaAddressId(
                            _controller.text.isEmpty
                                ? '(ID) не задан'
                                : _controller.text,
                            'YX1',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
