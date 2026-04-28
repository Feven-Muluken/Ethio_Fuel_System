import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../providers/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _licensePlateController = TextEditingController();

  @override
  void dispose() {
    _nationalIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = ref.read(authControllerProvider.notifier);
    await auth.registerBuyer(
      nationalId: _nationalIdController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      licensePlate: _licensePlateController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    final latestState = ref.read(authControllerProvider);
    if (latestState.errorMessage == null) {
      context.go('/approval');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
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
                      'Step 1: Initial Registration',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Submit National ID (Fayda), license plate, and at least one contact '
                      '(email or phone) for verification updates.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nationalIdController,
                      decoration: const InputDecoration(labelText: 'National ID (Fayda number)'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'National ID is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone number (optional)'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email (optional)'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _licensePlateController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'License plate'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'License plate is required' : null,
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final noPhone = _phoneController.text.trim().isEmpty;
                        final noEmail = _emailController.text.trim().isEmpty;
                        if (noPhone && noEmail) {
                          return const Text(
                            'Provide at least one contact method (email or phone).',
                            style: TextStyle(color: Colors.red),
                          );
                        }
                        return const SizedBox.shrink();
                      },
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
                      onPressed: authState.loading
                          ? null
                          : () async {
                              final noPhone = _phoneController.text.trim().isEmpty;
                              final noEmail = _emailController.text.trim().isEmpty;
                              if (noPhone && noEmail) {
                                setState(() {});
                                return;
                              }
                              await _submit();
                            },
                      child: Text(authState.loading ? 'Submitting...' : 'Submit for approval'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Already have an account? Login'),
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
