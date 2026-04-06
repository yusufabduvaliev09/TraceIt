import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';
import 'package:traceit/features/cargo/data/cargo_service.dart';
import 'package:traceit/features/cargo/domain/cargo_model.dart';
import 'package:traceit/features/cargo/domain/cargo_status.dart';

class TrackSearchScreen extends StatefulWidget {
  const TrackSearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<TrackSearchScreen> createState() => _TrackSearchScreenState();
}

class _TrackSearchScreenState extends State<TrackSearchScreen> {
  late final TextEditingController _q =
      TextEditingController(text: widget.initialQuery);

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final query = _q.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск трек-кода'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _q,
              decoration: const InputDecoration(
                labelText: 'Трек-номер',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CargoModel>>(
              stream: CargoService().getMyCargo(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snapshot.data ?? [];
                if (query.isEmpty) {
                  return const Center(
                    child: Text('Введите номер для поиска'),
                  );
                }
                final matches = all
                    .where(
                      (c) =>
                          c.trackCode.toLowerCase().contains(query) ||
                          c.title.toLowerCase().contains(query) ||
                          c.description.toLowerCase().contains(query),
                    )
                    .toList();
                if (matches.isEmpty) {
                  return const Center(child: Text('Ничего не найдено'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: matches.length,
                  itemBuilder: (context, i) {
                    final c = matches[i];
                    return Card(
                      child: ListTile(
                        title: Text(c.trackCode),
                        subtitle: Text(
                          '${CargoStatusKeys.labelRu(c.status)} · ${c.description.isNotEmpty ? c.description : c.title}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
