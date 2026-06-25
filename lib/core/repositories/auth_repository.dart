import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/api_user.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../storage/secure_storage_service.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({required String name, required String email, required String password, String? phone});
  Future<void> logout();
  Future<UserModel> profile();
  Future<UserModel> updateProfile({String? name, String? phone, String? avatar});
  Future<UserModel> uploadAvatar(XFile file);
  Future<UserModel> deleteAvatar();
}

class ApiAuthRepository implements AuthRepository {
  final _client = ApiClient().dio;

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await _client.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    final data = response.data;
    await SecureStorageService.saveToken(data['token']);
    await SecureStorageService.saveUser(data['user']);
    return UserModel.fromJson(data['user']);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _client.post(ApiConstants.register, data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      if (phone != null) 'phone': phone, // ignore: use_null_aware_elements
    });
    final data = response.data;
    await SecureStorageService.saveToken(data['token']);
    await SecureStorageService.saveUser(data['user']);
    return UserModel.fromJson(data['user']);
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } catch (_) {}
    await SecureStorageService.logout();
  }

  @override
  Future<UserModel> profile() async {
    final response = await _client.get(ApiConstants.profile);
    return UserModel.fromJson(response.data['data']);
  }

  @override
  Future<UserModel> updateProfile({String? name, String? phone, String? avatar}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (avatar != null) data['avatar'] = avatar;

    final response = await _client.put(ApiConstants.profile, data: data);
    final user = UserModel.fromJson(response.data['user']);
    await SecureStorageService.saveUser(user.toJson());
    return user;
  }

  @override
  Future<UserModel> uploadAvatar(XFile file) async {
    final bytes = await file.readAsBytes();
    final multipartFile = MultipartFile.fromBytes(
      bytes,
      filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final formData = FormData.fromMap({
      'avatar': multipartFile,
    });
    final response = await _client.post(
      ApiConstants.avatarUpload,
      data: formData,
    );
    final user = UserModel.fromJson(response.data['user']);
    await SecureStorageService.saveUser(user.toJson());
    return user;
  }

  @override
  Future<UserModel> deleteAvatar() async {
    final response = await _client.delete(ApiConstants.avatarDelete);
    final user = UserModel.fromJson(response.data['user']);
    await SecureStorageService.saveUser(user.toJson());
    return user;
  }
}
