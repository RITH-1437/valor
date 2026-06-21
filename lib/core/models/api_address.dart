class AddressModel {
  final int id;
  final int userId;
  final String fullName;
  final String phone;
  final String country;
  final String city;
  final String district;
  final String street;
  final String? postalCode;
  final bool isDefault;
  final String fullAddress;
  final DateTime? createdAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.country,
    required this.city,
    required this.district,
    required this.street,
    this.postalCode,
    this.isDefault = false,
    required this.fullAddress,
    this.createdAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      street: json['street'] ?? '',
      postalCode: json['postal_code'],
      isDefault: json['is_default'] ?? false,
      fullAddress: json['full_address'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
