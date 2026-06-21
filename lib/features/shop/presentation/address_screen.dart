import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/api_address_provider.dart';
import '../../../core/models/api_address.dart';
import '../../../shared/widgets/empty_state.dart';

class AddressScreen extends ConsumerWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('Shipping Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.gold),
            onPressed: () => _showAddressForm(context, ref),
          ),
        ],
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return EmptyState(
              icon: Icons.location_on_outlined,
              title: 'No addresses saved',
              subtitle: 'Add a shipping address for faster checkout',
              actionLabel: 'Add Address',
              onAction: () => _showAddressForm(context, ref),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (ctx, i) => _AddressCard(
              address: addresses[i],
              onEdit: () => _showAddressForm(context, ref, address: addresses[i]),
              onDelete: () => ref.read(addressProvider.notifier).remove(addresses[i].id),
              onSetDefault: () => ref.read(addressProvider.notifier).setDefault(addresses[i].id),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.gold)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.gray))),
      ),
    );
  }

  void _showAddressForm(BuildContext context, WidgetRef ref, {AddressModel? address}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkGray,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddressFormSheet(address: address),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({required this.address, required this.onEdit, required this.onDelete, required this.onSetDefault});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault ? Border.all(color: AppTheme.gold, width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(address.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              const Spacer(),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppTheme.gold, borderRadius: BorderRadius.circular(6)),
                  child: const Text('Default', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.black)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(address.phone, style: const TextStyle(color: AppTheme.gray, fontSize: 13)),
          const SizedBox(height: 4),
          Text(address.fullAddress, style: const TextStyle(color: AppTheme.gray, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!address.isDefault)
                TextButton(
                  onPressed: onSetDefault,
                  child: const Text('Set Default', style: TextStyle(color: AppTheme.gold, fontSize: 12)),
                ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppTheme.gray, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressFormSheet extends ConsumerStatefulWidget {
  final AddressModel? address;
  const _AddressFormSheet({this.address});

  @override
  ConsumerState<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _districtCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _postalCtrl;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _nameCtrl = TextEditingController(text: a?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: a?.phone ?? '');
    _countryCtrl = TextEditingController(text: a?.country ?? 'Vietnam');
    _cityCtrl = TextEditingController(text: a?.city ?? '');
    _districtCtrl = TextEditingController(text: a?.district ?? '');
    _streetCtrl = TextEditingController(text: a?.street ?? '');
    _postalCtrl = TextEditingController(text: a?.postalCode ?? '');
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _streetCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.gray, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(widget.address == null ? 'Add Address' : 'Edit Address', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              _field('Full Name', _nameCtrl),
              const SizedBox(height: 12),
              _field('Phone', _phoneCtrl, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _field('Country', _countryCtrl),
              const SizedBox(height: 12),
              _field('City', _cityCtrl),
              const SizedBox(height: 12),
              _field('District', _districtCtrl),
              const SizedBox(height: 12),
              _field('Street Address', _streetCtrl),
              const SizedBox(height: 12),
              _field('Postal Code', _postalCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (v) => setState(() => _isDefault = v ?? false),
                    activeColor: AppTheme.gold,
                    checkColor: AppTheme.black,
                  ),
                  const Text('Set as default address', style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (widget.address == null) {
                        await ref.read(addressProvider.notifier).add(
                          fullName: _nameCtrl.text.trim(),
                          phone: _phoneCtrl.text.trim(),
                          country: _countryCtrl.text.trim(),
                          city: _cityCtrl.text.trim(),
                          district: _districtCtrl.text.trim(),
                          street: _streetCtrl.text.trim(),
                          postalCode: _postalCtrl.text.trim().isNotEmpty ? _postalCtrl.text.trim() : null,
                          isDefault: _isDefault,
                        );
                      } else {
                        await ref.read(addressProvider.notifier).editAddress(
                          widget.address!.id,
                          fullName: _nameCtrl.text.trim(),
                          phone: _phoneCtrl.text.trim(),
                          country: _countryCtrl.text.trim(),
                          city: _cityCtrl.text.trim(),
                          district: _districtCtrl.text.trim(),
                          street: _streetCtrl.text.trim(),
                          postalCode: _postalCtrl.text.trim().isNotEmpty ? _postalCtrl.text.trim() : null,
                          isDefault: _isDefault,
                        );
                      }
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold, foregroundColor: AppTheme.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(widget.address == null ? 'Save Address' : 'Update Address', style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.gray),
        filled: true,
        fillColor: AppTheme.black,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
    );
  }
}
