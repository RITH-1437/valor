import 'package:dio/dio.dart';
import '../models/api_post.dart';
import '../network/api_client.dart';

abstract class SocialRepository {
  Future<List<PostModel>> getFeed({int page = 1});
  Future<List<PostModel>> getPosts({int page = 1});
  Future<PostModel> createPost({String? content, String? styleTags});
  Future<void> deletePost(int postId);
  Future<Map<String, dynamic>> toggleLike(int postId);
  Future<void> addComment(int postId, String comment);
  Future<void> toggleFollow(int userId);
  Future<bool> isFollowing(int userId);
}

class ApiSocialRepository implements SocialRepository {
  final _client = ApiClient().dio;

  @override
  Future<List<PostModel>> getFeed({int page = 1}) async {
    final response = await _client.get('/feed', queryParameters: {'page': page});
    final data = response.data['data'];
    return (data['data'] as List).map((e) => PostModel.fromJson(e)).toList();
  }

  @override
  Future<List<PostModel>> getPosts({int page = 1}) async {
    final response = await _client.get('/posts', queryParameters: {'page': page});
    final data = response.data['data'];
    return (data['data'] as List).map((e) => PostModel.fromJson(e)).toList();
  }

  @override
  Future<PostModel> createPost({String? content, String? styleTags}) async {
    final formData = FormData.fromMap({
      if (content != null) 'content': content, // ignore: use_null_aware_elements
      if (styleTags != null) 'style_tags': styleTags, // ignore: use_null_aware_elements
    });
    final response = await _client.post('/posts', data: formData);
    return PostModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deletePost(int postId) async {
    await _client.delete('/posts/$postId');
  }

  @override
  Future<Map<String, dynamic>> toggleLike(int postId) async {
    final response = await _client.post('/posts/$postId/like');
    return response.data;
  }

  @override
  Future<void> addComment(int postId, String comment) async {
    await _client.post('/posts/$postId/comment', data: {'comment': comment});
  }

  @override
  Future<void> toggleFollow(int userId) async {
    await _client.post('/users/$userId/follow');
  }

  @override
  Future<bool> isFollowing(int userId) async {
    return false;
  }
}
