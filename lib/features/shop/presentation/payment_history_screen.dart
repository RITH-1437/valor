import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/api_payment_provider.dart';
import '../../../core/models/api_payment.dart';
import '../../../shared/widgets/empty_state.dart';

final paymentHistoryProvider = FutureProvider<List<PaymentTransactionModel>>((ref) async {
  return ref.read(paymentRepositoryProvider).getPaymentHistory();
});

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(paymentHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(title: const Text('Payment History')),
      body: historyAsync.when(
        data: (payments) {
          if (payments.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No payments yet',
              subtitle: 'Your payment history will appear here',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (ctx, i) {
              final p = payments[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: _statusColor(p.status).withAlpha(30), borderRadius: BorderRadius.circular(10)),
                      child: Icon(_providerIcon(p.provider), color: _statusColor(p.status), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.provider.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(p.transactionId ?? 'N/A', style: const TextStyle(color: AppTheme.gray, fontSize: 11)),
                      ]),
                    ),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('\$${p.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      _statusBadge(p.status),
                    ]),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.gold)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.gray))),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid': return Colors.green;
      case 'pending': return Colors.orange;
      case 'failed': return Colors.redAccent;
      case 'cancelled': return AppTheme.gray;
      case 'refunded': return Colors.blue;
      default: return AppTheme.gray;
    }
  }

  IconData _providerIcon(String provider) {
    switch (provider) {
      case 'stripe': return Icons.credit_card_rounded;
      case 'paypal': return Icons.account_balance_wallet;
      case 'cod': return Icons.money;
      default: return Icons.payment;
    }
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: _statusColor(status).withAlpha(30), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: TextStyle(color: _statusColor(status), fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }
}
