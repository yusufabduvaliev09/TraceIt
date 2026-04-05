import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:traceit/core/widgets/cargo_card.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';
import 'package:traceit/features/cargo/data/cargo_service.dart';
import 'package:traceit/features/cargo/domain/cargo_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final CargoService _cargoService = CargoService();
  int _selectedIndex = 0;
  final List<String> _statuses = const [
    'pending',
    'transit',
    'warehouse',
    'delivered',
  ];

  Widget _buildCargoList({
    required String status,
    required String userUid,
  }) {
    return StreamBuilder<List<CargoModel>>(
      stream: _cargoService.getMyCargo(userUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Посылок пока нет'));
        }
        final filteredList =
            snapshot.data!.where((cargo) => cargo.status == status).toList();
        if (filteredList.isEmpty) {
          return const Center(child: Text('В этой категории пусто'));
        }
        return ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (context, index) => CargoCard(cargo: filteredList[index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: authProvider.userDocumentStream(),
      builder: (context, snapshot) {
        final isBlocked = (snapshot.data?['isBlocked'] ?? false) == true;
        if (isBlocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.logout();
          });
          return const Scaffold(
            body: Center(child: Text('Пользователь заблокирован администратором')),
          );
        }
        final role = (snapshot.data?['role'] ?? 'user').toString();
        final isAdminOrDev = role == 'admin' || role == 'dev';

        return Scaffold(
          appBar: AppBar(
            title: const Text('TraceIt'),
            actions: [
              IconButton(
                onPressed: () => context.push('/profile'),
                icon: const Icon(Icons.person),
              ),
              if (isAdminOrDev)
                TextButton.icon(
                  onPressed: () => context.push('/admin'),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Admin Panel'),
                ),
            ],
          ),
          body: _buildCargoList(
            status: _statuses[_selectedIndex],
            userUid: user.uid,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.hourglass_bottom),
                label: 'В ожидании',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping),
                label: 'В пути',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2),
                label: 'На складе',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle),
                label: 'Доставлено',
              ),
            ],
          ),
        );
      },
    );
  }
}