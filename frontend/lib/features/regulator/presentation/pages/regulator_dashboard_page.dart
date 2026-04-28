import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_controller.dart';

class RegulatorDashboardPage extends ConsumerWidget {
  const RegulatorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regulator Dashboard'),
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
          Card(child: ListTile(title: Text('Distribution Monitoring'), subtitle: Text('Real-time allocation and usage metrics'))),
          Card(child: ListTile(title: Text('Fraud Alerts'), subtitle: Text('Anomaly and suspicious behavior indicators'))),
          Card(child: ListTile(title: Text('Quota Adjustment'), subtitle: Text('Policy-driven quota rule updates'))),
          Card(child: ListTile(title: Text('Analytics and Reports'), subtitle: Text('Regulatory and operational reporting'))),
        ],
      ),
    );
  }
}
