import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:traceit/features/auth/components/auth_gradient_button.dart';
import 'package:traceit/features/auth/components/kg_phone_formatter.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';
import 'package:traceit/features/pvz/data/pvz_service.dart';
import 'package:traceit/features/pvz/domain/pvz_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: KgPhoneFormatter.prefix);
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedPvzDocId;
  final _pvzService = PvzService();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPvzDocId == null || _selectedPvzDocId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите ПВЗ')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    await auth.register(
      name: _nameController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      pvzDocId: _selectedPvzDocId!,
    );
    if (!mounted) return;
    if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!)),
      );
      return;
    }
    context.go('/main');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Имя',
              prefixIcon: Icon(FontAwesomeIcons.user),
            ),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Введите имя' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [KgPhoneFormatter()],
            decoration: const InputDecoration(
              labelText: 'Номер телефона',
              prefixIcon: Icon(FontAwesomeIcons.phone),
            ),
            validator: (value) =>
                (value == null || value.replaceAll(' ', '').length < 13)
                    ? 'Введите номер +996'
                    : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Пароль',
              prefixIcon: Icon(FontAwesomeIcons.lock),
            ),
            obscureText: true,
            validator: (value) =>
                (value == null || value.length < 6) ? 'Минимум 6 символов' : null,
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<PvzModel>>(
            stream: _pvzService.watchPvzList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'ПВЗ пока не добавлены. Обратитесь к администратору.',
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                );
              }
              return InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Выберите ПВЗ',
                  prefixIcon: Icon(FontAwesomeIcons.warehouse),
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedPvzDocId != null &&
                            list.any((p) => p.id == _selectedPvzDocId)
                        ? _selectedPvzDocId
                        : null,
                    hint: const Text('Пункт выдачи'),
                    items: list
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.displayLabel),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPvzDocId = v),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          AuthGradientButton(
            onPressed: auth.isLoading ? null : _submit,
            label: 'Зарегистрироваться',
            isLoading: auth.isLoading,
          ),
        ],
      ),
    );
  }
}
