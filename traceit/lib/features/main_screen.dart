import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:traceit/core/constants/company_info.dart';
import 'package:traceit/core/utils/china_address_template.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';
import 'package:traceit/features/cargo/data/cargo_service.dart';
import 'package:traceit/features/cargo/domain/cargo_model.dart';
import 'package:traceit/features/cargo/domain/cargo_status.dart';
import 'package:traceit/features/home/presentation/abu_app_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CargoService _cargoService = CargoService();

  int _bodyIndex = 0;
  int _navBarIndex = 0;
  bool _notificationGranted = true;
  final TextEditingController _parcelsSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotificationPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _parcelsSearch.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshNotificationPermission();
    }
  }

  Future<void> _refreshNotificationPermission() async {
    final granted = await Permission.notification.isGranted;
    if (mounted) setState(() => _notificationGranted = granted);
  }

  Future<void> _openOsNotificationSettings() => openAppSettings();

  String _resolveChinaAddress({
    required String template,
    required String plainFallback,
    required String customerId,
  }) {
    if (template.isNotEmpty) {
      return applyChinaAddressId(template, customerId);
    }
    if (plainFallback.isNotEmpty) {
      if (plainFallback.contains('(ID)') || plainFallback.contains('{ID}')) {
        return applyChinaAddressId(plainFallback, customerId);
      }
      return plainFallback;
    }
    return 'Guangzhou, Baiyun District, Warehouse №7, Code: $customerId';
  }

  void _showInfoModal(BuildContext context, Map<String, dynamic>? userData) {
    final name = (userData?['name'] ?? '—').toString();
    final id = (userData?['customerId'] ?? '—').toString();
    final pvzName = (userData?['pvzName'] ?? '').toString();
    final pvzAddr = (userData?['pvzAddress'] ?? '').toString();
    final pvzLegacy = (userData?['pvz'] ?? '—').toString();
    final pvzLine = pvzName.isNotEmpty
        ? (pvzAddr.isNotEmpty ? '$pvzName · $pvzAddr' : pvzName)
        : pvzLegacy;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.paddingOf(ctx).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Информация',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _infoRow('Имя клиента', name),
              _infoRow('ID клиента', id),
              _infoRow('ПВЗ', pvzLine),
              const Divider(height: 32),
              Text(
                'Контакты ${CompanyInfo.name}',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(CompanyInfo.phone),
              Text(CompanyInfo.email),
              Text(CompanyInfo.messengers),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _showAddParcelDialog(
    BuildContext context, {
    required String uid,
    required Map<String, dynamic>? userData,
  }) async {
    final track = TextEditingController();
    final desc = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Добавить посылку'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: track,
                decoration: const InputDecoration(labelText: 'Трек-код'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: desc,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () async {
                if (track.text.trim().isEmpty) return;
                await _cargoService.addUserParcel(
                  ownerUid: uid,
                  ownerName: (userData?['name'] ?? '').toString(),
                  ownerCustomerId: (userData?['customerId'] ?? '').toString(),
                  trackCode: track.text,
                  description: desc.text,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Посылка добавлена')),
                  );
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    Map<String, dynamic>? userData, {
    required bool isAdminOrDev,
  }) {
    final name = (userData?['name'] ?? 'Клиент').toString();
    final phone = (userData?['phone'] ?? '').toString();

    switch (_bodyIndex) {
      case 0:
        return AppBar(
          title: const Text('ABU Cargo'),
          leading: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/track-search'),
            tooltip: 'Поиск трек-кодов',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push('/notifications'),
              tooltip: 'Уведомления',
            ),
            if (isAdminOrDev)
              IconButton(
                icon: const Icon(Icons.admin_panel_settings_outlined),
                onPressed: () => context.push('/admin'),
                tooltip: 'Админ',
              ),
            PopupMenuButton<String>(
              tooltip: name,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline, size: 22),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 96),
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (phone.isNotEmpty) Text(phone),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Выйти'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value != 'logout') return;
                await context.read<AuthProvider>().logout();
                if (context.mounted) context.go('/auth');
              },
            ),
          ],
        );
      case 1:
        return AppBar(title: const Text('Мои посылки'));
      case 2:
        return AppBar(title: const Text('Юань'));
      default:
        return AppBar(title: const Text('ABU Cargo'));
    }
  }

  Widget _buildHomeBody(
    BuildContext context, {
    required String uid,
    required Map<String, dynamic>? userData,
  }) {
    final customerId = (userData?['customerId'] ?? '—').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_notificationGranted)
          Material(
            color: Colors.amber.withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_outlined, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Включите уведомления, чтобы получать инфо о статусе посылок',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: _openOsNotificationSettings,
                    child: const Text('Включить'),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showAddParcelDialog(
                        context,
                        uid: uid,
                        userData: userData,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showInfoModal(context, userData),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Информация'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Статусы',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...CargoStatusKeys.homeOrder.map((key) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push('/cargo/$key'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                CargoStatusKeys.labelRu(key),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Text(
                'Адрес склада в Китае',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              StreamBuilder<String>(
                stream: _cargoService.watchChinaAddressTemplate(),
                builder: (context, templateSnap) {
                  return StreamBuilder<String>(
                    stream: _cargoService.watchChinaWarehouseAddress(),
                    builder: (context, plainSnap) {
                      final template = (templateSnap.data ?? '').trim();
                      final plain = (plainSnap.data ?? '').trim();
                      final text = _resolveChinaAddress(
                        template: template,
                        plainFallback: plain,
                        customerId: customerId,
                      );
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(text),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final template =
                      (await _cargoService.readChinaAddressTemplateOnce())
                          .trim();
                  final plain =
                      (await _cargoService.readChinaWarehouseAddressOnce())
                          .trim();
                  final text = _resolveChinaAddress(
                    template: template,
                    plainFallback: plain,
                    customerId: customerId,
                  );
                  await Clipboard.setData(ClipboardData(text: text));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Адрес скопирован')),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
                label: const Text('Скопировать весь адрес'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParcelsBody(
    String uid,
    Map<String, dynamic>? userData,
  ) {
    final q = _parcelsSearch.text.trim().toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Мои посылки',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton.icon(
            onPressed: () => _showAddParcelDialog(
              context,
              uid: uid,
              userData: userData,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Добавить код'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _parcelsSearch,
            decoration: const InputDecoration(
              labelText: 'Поиск по трек-коду / штрихкоду',
              prefixIcon: Icon(Icons.qr_code_scanner_outlined),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<CargoModel>>(
            stream: _cargoService.getMyCargo(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              var list = snapshot.data ?? [];
              if (q.isNotEmpty) {
                list = list
                    .where(
                      (c) =>
                          c.trackCode.toLowerCase().contains(q) ||
                          c.title.toLowerCase().contains(q),
                    )
                    .toList();
              }
              if (list.isEmpty) {
                return const Center(child: Text('Нет посылок'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final c = list[i];
                  return Card(
                    child: ListTile(
                      title: Text(c.trackCode),
                      subtitle: Text(CargoStatusKeys.labelRu(c.status)),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
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
        final userData = snapshot.data;
        final isBlocked = (userData?['isBlocked'] ?? false) == true;
        if (isBlocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.logout();
          });
          return const Scaffold(
            body: Center(
              child: Text('Пользователь заблокирован администратором'),
            ),
          );
        }

        final role = (userData?['role'] ?? 'user').toString();
        final isAdminOrDev = role == 'admin' || role == 'dev';
        final displayName = (userData?['name'] ?? 'Клиент').toString();

        return Scaffold(
          key: _scaffoldKey,
          appBar: _buildAppBar(
            context,
            userData,
            isAdminOrDev: isAdminOrDev,
          ),
          drawer: AbuAppDrawer(
            userName: displayName,
            isAdminOrDev: isAdminOrDev,
            onHome: () => setState(() {
              _bodyIndex = 0;
              _navBarIndex = 0;
            }),
            onParcels: () => setState(() {
              _bodyIndex = 1;
              _navBarIndex = 1;
            }),
          ),
          body: IndexedStack(
            index: _bodyIndex,
            children: [
              _buildHomeBody(context, uid: user.uid, userData: userData),
              _buildParcelsBody(user.uid, userData),
              const Center(
                child: Text(
                  'Юань',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _navBarIndex,
            onDestinationSelected: (i) {
              if (i == 3) {
                _scaffoldKey.currentState?.openDrawer();
                return;
              }
              setState(() {
                _navBarIndex = i;
                _bodyIndex = i;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Главная',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Посылки',
              ),
              NavigationDestination(
                icon: Icon(Icons.payments_outlined),
                selectedIcon: Icon(Icons.payments),
                label: 'Юань',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu),
                selectedIcon: Icon(Icons.menu_open),
                label: 'Меню',
              ),
            ],
          ),
        );
      },
    );
  }
}
