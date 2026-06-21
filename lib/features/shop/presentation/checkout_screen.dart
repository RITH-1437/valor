import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/api_cart_provider.dart';
import '../../../core/providers/api_order_provider.dart';
import '../../../core/providers/api_address_provider.dart';
import '../../../core/models/api_address.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  AddressModel? _selectedAddress;
  String _paymentMethod = 'credit_card';
  bool _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    final cartState = cartAsync.value;
    final meta = cartState?.meta;
    final addressesAsync = ref.watch(addressProvider);

    if (cartState == null || cartState.items.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.black,
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Your cart is empty', style: TextStyle(color: AppTheme.gray))),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(title: const Text('Checkout')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () async {
          if (_currentStep == 0 && _selectedAddress == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a shipping address'), backgroundColor: Colors.redAccent),
            );
            return;
          }
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            await _placeOrder();
          }
        },
        onStepCancel: () { if (_currentStep > 0) setState(() => _currentStep--); },
        controlsBuilder: (ctx, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isPlacingOrder ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold, foregroundColor: AppTheme.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _isPlacingOrder
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.black))
                        : Text(_currentStep == 2 ? 'Place Order' : 'Continue', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (_currentStep > 0) TextButton(onPressed: details.onStepCancel, child: const Text('Back', style: TextStyle(color: AppTheme.gray))),
            ],
          ),
        ),
        steps: [
          // Step 1: Shipping Address
          Step(
            title: const Text('Shipping Address', style: TextStyle(color: Colors.white)),
            isActive: _currentStep >= 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                addressesAsync.when(
                  data: (addresses) {
                    if (addresses.isEmpty) {
                      return TextButton.icon(
                        onPressed: () => context.push('/addresses'),
                        icon: const Icon(Icons.add, color: AppTheme.gold),
                        label: const Text('Add a shipping address', style: TextStyle(color: AppTheme.gold)),
                      );
                    }
                    return Column(
                      children: addresses.map((addr) => GestureDetector(
                        onTap: () => setState(() => _selectedAddress = addr),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _selectedAddress?.id == addr.id ? AppTheme.gold.withAlpha(25) : AppTheme.darkGray,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _selectedAddress?.id == addr.id ? AppTheme.gold : Colors.transparent),
                          ),
                          child: Row(
                            children: [
                              Icon(_selectedAddress?.id == addr.id ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: AppTheme.gold, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${addr.fullName} • ${addr.phone}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text(addr.fullAddress, style: const TextStyle(color: AppTheme.gray, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )).toList(),
                    );
                  },
                  loading: () => const CircularProgressIndicator(color: AppTheme.gold),
                  error: (_, _) => const Text('Failed to load addresses', style: TextStyle(color: AppTheme.gray)),
                ),
                TextButton(
                  onPressed: () => context.push('/addresses'),
                  child: const Text('Manage addresses', style: TextStyle(color: AppTheme.gold, fontSize: 12)),
                ),
              ],
            ),
          ),

          // Step 2: Payment
          Step(
            title: const Text('Payment Method', style: TextStyle(color: Colors.white)),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                _paymentOption('credit_card', 'Credit Card', Icons.credit_card),
                const SizedBox(height: 8),
                _paymentOption('debit_card', 'Debit Card', Icons.payment),
                const SizedBox(height: 8),
                _paymentOption('cash_on_delivery', 'Cash on Delivery', Icons.money),
              ],
            ),
          ),

          // Step 3: Review
          Step(
            title: const Text('Review Order', style: TextStyle(color: Colors.white)),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Items
                const Text('Items', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...cartState.items.map((item) {
                  final p = item.product;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${p?.name ?? "Product"} x${item.quantity}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                              if (item.selectedSize != null || item.selectedColor != null)
                                Text('${item.selectedSize ?? ""} / ${item.selectedColor ?? ""}', style: const TextStyle(color: AppTheme.gray, fontSize: 11)),
                            ],
                          ),
                        ),
                        Text('\$${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }),
                const Divider(color: AppTheme.darkGray, height: 20),

                // Address
                if (_selectedAddress != null) ...[
                  const Text('Ship to', style: TextStyle(color: AppTheme.gray, fontSize: 12)),
                  Text(_selectedAddress!.fullAddress, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  const SizedBox(height: 12),
                ],

                // Totals
                if (meta != null) ...[
                  _row('Subtotal', '\$${meta.subtotal.toStringAsFixed(2)}'),
                  _row('Shipping', meta.shipping == 0 ? 'FREE' : '\$${meta.shipping.toStringAsFixed(2)}'),
                  _row('Total', '\$${meta.total.toStringAsFixed(2)}', isTotal: true),
                ],
                const SizedBox(height: 8),
                Text('Payment: ${_paymentMethod.replaceAll('_', ' ').toUpperCase()}', style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
              ],
            ),
          ),
        ],
        type: StepperType.vertical,
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) return;

    setState(() => _isPlacingOrder = true);

    final address = '${_selectedAddress!.street}, ${_selectedAddress!.district}, ${_selectedAddress!.city}, ${_selectedAddress!.country}';
    final order = await ref.read(orderProvider.notifier).placeOrder(
      shippingAddress: address,
      paymentMethod: _paymentMethod,
    );

    setState(() => _isPlacingOrder = false);

    if (order != null && mounted) {
      context.go('/orders');
    }
  }

  Widget _paymentOption(String method, String label, IconData icon) {
    final selected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.gold.withAlpha(25) : AppTheme.darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.gold : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppTheme.gold : Colors.white),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: selected ? AppTheme.gold : Colors.white, fontWeight: FontWeight.w600)),
            const Spacer(),
            if (selected) const Icon(Icons.check_circle, color: AppTheme.gold, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isTotal ? Colors.white : AppTheme.gray, fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400)),
          Text(value, style: TextStyle(color: isTotal ? Colors.white : AppTheme.gold, fontWeight: FontWeight.w700, fontSize: isTotal ? 18 : 14)),
        ],
      ),
    );
  }
}
