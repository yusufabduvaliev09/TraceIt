import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:traceit/features/auth/components/auth_gradient_button.dart';
import 'package:traceit/features/auth/components/kg_phone_formatter.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';

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
  String _selectedPvz = 'Бишкек, Склад №1';

  final List<String> _pvzOptions = const [
    'Бишкек, Склад №1',
    'Ош, Склад №2',
    'Чуй, Склад №3',
    'Иссык-Куль, Склад №4',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.register(
      name: _nameController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      pvz: _selectedPvz,
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
          DropdownButtonFormField<String>(
            initialValue: _selectedPvz,
            decoration: const InputDecoration(
              labelText: 'Выберите ПВЗ',
              prefixIcon: Icon(FontAwesomeIcons.warehouse),
            ),
            items: _pvzOptions
                .map((pvz) => DropdownMenuItem(value: pvz, child: Text(pvz)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedPvz = value);
              }
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
