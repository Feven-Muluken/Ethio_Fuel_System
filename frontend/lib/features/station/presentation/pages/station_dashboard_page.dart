import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_controller.dart';

class StationDashboardPage extends ConsumerWidget {
  const StationDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Station Portal'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(title: Text('Scan QR / Enter Plate'), subtitle: Text('Validate fuel pass in real time'))),
          Card(child: ListTile(title: Text('Quota Validation'), subtitle: Text('Prevent over-allocation before fueling'))),
          Card(child: ListTile(title: Text('Record Transaction'), subtitle: Text('Persist liters, station, and timestamp'))),
          Card(child: ListTile(title: Text('Daily Report'), subtitle: Text('Station-level aggregated activity'))),
        ],
      ),
    );
  }
}
