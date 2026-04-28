import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FuelPurchasePage extends StatefulWidget {
  const FuelPurchasePage({super.key});

  @override
  State<FuelPurchasePage> createState() => _FuelPurchasePageState();
}

class _FuelPurchasePageState extends State<FuelPurchasePage> {
  final _formKey = GlobalKey<FormState>();
  final _stationController = TextEditingController();
  final _litersController = TextEditingController();
  bool _processing = false;
  String? _resultMessage;

  @override
  void dispose() {
    _stationController.dispose();
    _litersController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _processing = true;
      _resultMessage = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 450));

    if (!mounted) {
      return;
    }
    setState(() {
      _processing = false;
      _resultMessage = 'Fuel purchase confirmed at ${_stationController.text.trim()} '
          'for ${_litersController.text.trim()} liters.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step 4: Fuel Purchase at Station')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
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
                      'Station transaction flow',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use QR or license plate validation, then record liters dispensed.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stationController,
                      decoration: const InputDecoration(labelText: 'Station code/name'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Station is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _litersController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Liters purchased'),
                      validator: (value) {
                        final liters = double.tryParse(value?.trim() ?? '');
                        if (liters == null || liters <= 0) {
                          return 'Enter a valid liters value';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _processing ? null : _submit,
                      child: Text(_processing ? 'Processing...' : 'Confirm Purchase'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context.go('/buyer'),
                      child: const Text('Back to Dashboard'),
                    ),
                    if (_resultMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _resultMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
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
