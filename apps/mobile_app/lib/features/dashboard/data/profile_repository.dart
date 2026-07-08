import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/dio_client.dart';
import '../domain/profile_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(dioProvider));
});

class ProfileRepository {
  final Dio _dio;
  ProfileRepository(this._dio);

  Future<UserProfile> getProfile() async {
    final response = await _dio.get('/users/me');
    return UserProfile.fromJson(response.data);
  }

  Future<UserProfile> updateProfile(String? displayName, String? title) async {
    final data = <String, dynamic>{};
    if (displayName != null && displayName.isNotEmpty)
      data['display_name'] = displayName;
    if (title != null && title.isNotEmpty) data['title'] = title;

    final response = await _dio.put('/users/me', data: data);
    return UserProfile.fromJson(response.data);
  }

  Future<String> uploadAvatar(XFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(await file.readAsBytes(),
          filename: file.name),
    });

    final response = await _dio.post('/users/me/avatar', data: formData);
    return response.data['avatar_url'];
  }
}
