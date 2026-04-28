import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_controller.dart';

class BuyerDashboardPage extends ConsumerWidget {
  const BuyerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
        children: [
          const Card(
            child: ListTile(
              title: Text('Current fuel quota'),
              subtitle: Text('Daily: 20L | Weekly: 90L'),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Remaining liters'),
              subtitle: Text('Daily remaining: 14.5L | Weekly remaining: 62L'),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Transaction history'),
              subtitle: Text('Recent purchases and station records'),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Generate QR code'),
              subtitle: Text('Create pass linked to your license plate for station scanning'),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.go('/fuel-purchase'),
            icon: const Icon(Icons.local_gas_station_outlined),
            label: const Text('Proceed to Fuel Purchase at Station'),
          ),
        ],
      ),
    );
  }
}
