import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_address.dart';
import '../repositories/address_repository.dart';
import 'auth_provider.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository();
});

class AddressNotifier extends AsyncNotifier<List<AddressModel>> {
  @override
  Future<List<AddressModel>> build() async {
    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) return [];
    return ref.read(addressRepositoryProvider).getAddresses();
  }

  Future<AddressModel?> add({
    required String fullName,
    required String phone,
    required String country,
    required String city,
    required String district,
    required String street,
    String? postalCode,
    bool isDefault = false,
  }) async {
    try {
      final address = await ref.read(addressRepositoryProvider).createAddress(
        fullName: fullName, phone: phone, country: country,
        city: city, district: district, street: street,
        postalCode: postalCode, isDefault: isDefault,
      );
      ref.invalidateSelf();
      return address;
    } catch (_) {
      return null;
    }
  }

  Future<void> editAddress(int id, {
    String? fullName, String? phone, String? country,
    String? city, String? district, String? street,
    String? postalCode, bool? isDefault,
  }) async {
    try {
      await ref.read(addressRepositoryProvider).updateAddress(id,
        fullName: fullName, phone: phone, country: country,
        city: city, district: district, street: street,
        postalCode: postalCode, isDefault: isDefault,
      );
      ref.invalidateSelf();
    } catch (_) {}
  }

  Future<void> remove(int id) async {
    try {
      await ref.read(addressRepositoryProvider).deleteAddress(id);
      ref.invalidateSelf();
    } catch (_) {}
  }

  Future<void> setDefault(int id) async {
    try {
      await ref.read(addressRepositoryProvider).setDefault(id);
      ref.invalidateSelf();
    } catch (_) {}
  }
}

final addressProvider = AsyncNotifierProvider<AddressNotifier, List<AddressModel>>(AddressNotifier.new);
