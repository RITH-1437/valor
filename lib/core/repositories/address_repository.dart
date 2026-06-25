import '../models/api_address.dart';
import '../network/api_client.dart';

abstract class AddressRepository {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> createAddress({required String fullName, required String phone, required String country, required String city, required String district, required String street, String? postalCode, bool isDefault = false});
  Future<AddressModel> updateAddress(int id, {String? fullName, String? phone, String? country, String? city, String? district, String? street, String? postalCode, bool? isDefault});
  Future<void> deleteAddress(int id);
  Future<AddressModel> setDefault(int id);
}

class ApiAddressRepository implements AddressRepository {
  final _client = ApiClient().dio;

  @override
  Future<List<AddressModel>> getAddresses() async {
    final response = await _client.get('/addresses');
    final data = response.data['data'] as List;
    return data.map((e) => AddressModel.fromJson(e)).toList();
  }

  @override
  Future<AddressModel> createAddress({
    required String fullName,
    required String phone,
    required String country,
    required String city,
    required String district,
    required String street,
    String? postalCode,
    bool isDefault = false,
  }) async {
    final response = await _client.post('/addresses', data: {
      'full_name': fullName,
      'phone': phone,
      'country': country,
      'city': city,
      'district': district,
      'street': street,
      'postal_code': postalCode,
      'is_default': isDefault,
    });
    return AddressModel.fromJson(response.data['data']);
  }

  @override
  Future<AddressModel> updateAddress(int id, {
    String? fullName,
    String? phone,
    String? country,
    String? city,
    String? district,
    String? street,
    String? postalCode,
    bool? isDefault,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (country != null) data['country'] = country;
    if (city != null) data['city'] = city;
    if (district != null) data['district'] = district;
    if (street != null) data['street'] = street;
    if (postalCode != null) data['postal_code'] = postalCode;
    if (isDefault != null) data['is_default'] = isDefault;

    final response = await _client.put('/addresses/$id', data: data);
    return AddressModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteAddress(int id) async {
    await _client.delete('/addresses/$id');
  }

  @override
  Future<AddressModel> setDefault(int id) async {
    final response = await _client.post('/addresses/$id/default');
    return AddressModel.fromJson(response.data['data']);
  }
}
