import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';

class ApprovalPage extends ConsumerStatefulWidget {
  const ApprovalPage({super.key});

  @override
  ConsumerState<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends ConsumerState<ApprovalPage> {
  BuyerProfile? _profile;
  bool _loading = true;
  final _rejectionReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = ref.read(authControllerProvider.notifier);
    final profile = await auth.getBuyerProfile();
    if (!mounted) {
      return;
    }
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  Future<void> _approve() async {
    final auth = ref.read(authControllerProvider.notifier);
    await auth.approveBuyerRegistration();
    await _load();
  }

  Future<void> _reject() async {
    final reason = _rejectionReasonController.text.trim();
    if (reason.isEmpty) {
      return;
    }
    final auth = ref.read(authControllerProvider.notifier);
    await auth.rejectBuyerRegistration(reason: reason);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration Approval')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _profile == null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'No registration found',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text('Please register before checking approval status.'),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => context.go('/register'),
                              child: const Text('Go to Registration'),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Step 2: Verification (Admin / Car Agencies)',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text('National ID: ${_profile!.nationalId}'),
                            Text('Phone: ${_profile!.phoneNumber}'),
                            if ((_profile!.email ?? '').isNotEmpty) Text('Email: ${_profile!.email}'),
                            Text('License plate: ${_profile!.licensePlate}'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text('Verification status: '),
                                Text(
                                  _profile!.verificationStatus.name.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _profile!.verificationStatus == BuyerVerificationStatus.approved
                                        ? Colors.green
                                        : _profile!.verificationStatus == BuyerVerificationStatus.rejected
                                            ? Colors.red
                                            : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            if (_profile!.verificationStatus == BuyerVerificationStatus.rejected &&
                                (_profile!.rejectionReason ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Rejection reason: ${_profile!.rejectionReason}'),
                            ],
                            const SizedBox(height: 20),
                            if (_profile!.verificationStatus == BuyerVerificationStatus.pending) ...[
                              const Text(
                                'Prototype admin actions for verification:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilledButton(
                                    onPressed: _approve,
                                    child: const Text('Mark as Approved'),
                                  ),
                                  OutlinedButton(
                                    onPressed: _load,
                                    child: const Text('Refresh Status'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _rejectionReasonController,
                                decoration: const InputDecoration(
                                  labelText: 'Rejection reason (required to reject)',
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: _reject,
                                child: const Text('Reject Registration'),
                              ),
                            ],
                            if (_profile!.verificationStatus == BuyerVerificationStatus.approved) ...[
                              const Card(
                                child: ListTile(
                                  leading: Icon(Icons.notifications_active_outlined),
                                  title: Text('Step 3: Notification Sent'),
                                  subtitle: Text(
                                    'Your registration has been approved. Please finish setup.',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              FilledButton(
                                onPressed: () => context.go('/pin-setup'),
                                child: const Text('Continue to PIN Setup'),
                              ),
                            ],
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text('Go to Login'),
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
