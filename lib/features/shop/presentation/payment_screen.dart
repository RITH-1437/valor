import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/api_payment_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final int orderId;
  final double total;
  final String orderNumber;

  const PaymentScreen({super.key, required this.orderId, required this.total, required this.orderNumber});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedProvider = 'cod';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(title: const Text('Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order: ${widget.orderNumber}', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Total: \$${widget.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Select Payment Method', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),

            _paymentOption('cod', 'Cash on Delivery', 'Pay when you receive your order', FontAwesomeIcons.moneyBill),
            const SizedBox(height: 12),
            _paymentOption('stripe', 'Credit / Debit Card', 'Secure payment via Stripe', FontAwesomeIcons.creditCard),
            const SizedBox(height: 12),
            _paymentOption('paypal', 'PayPal', 'Pay with your PayPal account', FontAwesomeIcons.paypal),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: AppTheme.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isProcessing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.black))
                    : Text('Pay \$${widget.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption(String provider, String title, String subtitle, dynamic icon) {
    final selected = _selectedProvider == provider;
    Widget iconWidget = const SizedBox.shrink();
    if (icon is FaIconData) {
      iconWidget = FaIcon(icon, color: selected ? AppTheme.gold : Colors.white, size: 24);
    } else if (icon is IconData) {
      iconWidget = Icon(icon, color: selected ? AppTheme.gold : Colors.white, size: 28);
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedProvider = provider),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.gold.withAlpha(25) : AppTheme.darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.gold : Colors.transparent),
        ),
        child: Row(
          children: [
            SizedBox(width: 32, child: Center(child: iconWidget)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(color: selected ? AppTheme.gold : Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: selected ? Colors.white70 : AppTheme.gray, fontSize: 12)),
              ]),
            ),
            if (selected) const FaIcon(FontAwesomeIcons.circleCheck, color: AppTheme.gold, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      final payment = await ref.read(paymentRepositoryProvider).createPayment(
        orderId: widget.orderId,
        provider: _selectedProvider,
        paymentMethod: _selectedProvider,
      );

      if (_selectedProvider == 'cod') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Order confirmed! Pay on delivery.'), backgroundColor: AppTheme.gold),
          );
          context.go('/orders');
        }
      } else {
        // For Stripe/PayPal, simulate payment verification
        await ref.read(paymentRepositoryProvider).verifyPayment(payment.id, 'paid');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Payment successful!'), backgroundColor: Colors.green),
          );
          context.go('/orders');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
