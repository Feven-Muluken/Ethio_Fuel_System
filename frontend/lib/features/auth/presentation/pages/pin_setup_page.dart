import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';

class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({super.key});

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nationalIdController.dispose();
    _licensePlateController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final auth = ref.read(authControllerProvider.notifier);
    final result = await auth.setupBuyerPin(
      nationalId: _nationalIdController.text.trim(),
      licensePlate: _licensePlateController.text.trim(),
      pin: _pinController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (result != null) {
      setState(() {
        _error = result;
        _submitting = false;
      });
      return;
    }

    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN setup completed. You can now login.')),
    );
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step 4: Final Registration (PIN Setup)')),
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
                      'Confirm identity and create secure PIN',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nationalIdController,
                      decoration: const InputDecoration(labelText: 'National ID'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'National ID is required' : null,
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
                    TextFormField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'PIN (4-6 digits)'),
                      validator: (value) {
                        final pin = value?.trim() ?? '';
                        final pinRegex = RegExp(r'^\d{4,6}$');
                        if (!pinRegex.hasMatch(pin)) {
                          return 'PIN must be 4 to 6 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Confirm PIN'),
                      validator: (value) {
                        if (value?.trim() != _pinController.text.trim()) {
                          return 'PINs do not match';
                        }
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: Text(_submitting ? 'Saving PIN...' : 'Save PIN and Continue'),
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
