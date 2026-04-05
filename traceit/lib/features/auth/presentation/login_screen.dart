import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:traceit/features/auth/components/auth_gradient_button.dart';
import 'package:traceit/features/auth/components/kg_phone_formatter.dart';
import 'package:traceit/features/auth/presentation/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: KgPhoneFormatter.prefix);
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.login(
      phone: _phoneController.text,
      password: _passwordController.text,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          const SizedBox(height: 20),
          AuthGradientButton(
            onPressed: auth.isLoading ? null : _submit,
            label: 'Войти',
            isLoading: auth.isLoading,
          ),
        ],
      ),
    );
  }
}
