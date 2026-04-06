import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';

class AbuAppDrawer extends StatelessWidget {
  const AbuAppDrawer({
    super.key,
    required this.userName,
    required this.onHome,
    required this.onParcels,
    required this.isAdminOrDev,
  });

  final String userName;
  final VoidCallback onHome;
  final VoidCallback onParcels;
  final bool isAdminOrDev;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                    Theme.of(context).colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'ABU Cargo',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userName.isEmpty ? 'Клиент' : userName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Главная'),
              onTap: () {
                Navigator.pop(context);
                onHome();
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Мои посылки'),
              onTap: () {
                Navigator.pop(context);
                onParcels();
              },
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Грузы на карте'),
              onTap: () {
                Navigator.pop(context);
                context.push('/map-route');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Неизвестные посылки'),
              onTap: () {
                Navigator.pop(context);
                context.push('/unknown-parcels');
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Инструкция'),
              onTap: () {
                Navigator.pop(context);
                context.push('/instruction');
              },
            ),
            if (isAdminOrDev)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: const Text('Админ-панель'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/admin');
                },
              ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Выход'),
              onTap: () async {
                Navigator.pop(context);
                await auth.logout();
                if (context.mounted) context.go('/auth');
              },
            ),
          ],
        ),
      ),
    );
  }
}
