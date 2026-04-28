import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../providers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _pinController = TextEditingController();
  final _licensePlateController = TextEditingController();

  @override
  void dispose() {
    _nationalIdController.dispose();
    _pinController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = ref.read(authControllerProvider.notifier);
    await auth.loginBuyer(
      nationalId: _nationalIdController.text.trim(),
      licensePlate: _licensePlateController.text.trim(),
      pin: _pinController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Step 5: Login',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter National ID, PIN, and license plate. '
                      'Django backend will issue JWT access tokens.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nationalIdController,
                      decoration: const InputDecoration(labelText: 'National ID'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'National ID is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'PIN'),
                      validator: (value) {
                        final pin = value?.trim() ?? '';
                        if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
                          return 'PIN must be 4 to 6 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _licensePlateController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'License plate'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'License plate is required' : null,
                    ),
                    if (authState.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        authState.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: authState.loading ? null : _submit,
                      child: Text(authState.loading ? 'Logging in...' : 'Login'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('No account? Start registration'),
                    ),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

