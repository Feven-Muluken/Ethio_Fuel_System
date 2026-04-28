import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ethio Fuel Pass Prototype',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Flow: Initial registration -> Verification -> Notification -> PIN setup '
                    '-> Login -> Dashboard -> Fuel purchase at station.',
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('1) Start Registration'),
                      ),
                      OutlinedButton(
                        onPressed: () => context.go('/approval'),
                        child: const Text('2) Verification Status'),
                      ),
                      OutlinedButton(
                        onPressed: () => context.go('/pin-setup'),
                        child: const Text('3) PIN Setup'),
                      ),
                      FilledButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('4) Login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
