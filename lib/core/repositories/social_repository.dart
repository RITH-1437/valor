import 'package:dio/dio.dart';
import '../models/api_post.dart';
import '../network/api_client.dart';

class SocialRepository {
  final _client = ApiClient().dio;

  Future<List<PostModel>> getFeed({int page = 1}) async {
    final response = await _client.get('/feed', queryParameters: {'page': page});
    final data = response.data['data'];
    return (data['data'] as List).map((e) => PostModel.fromJson(e)).toList();
  }

  Future<List<PostModel>> getPosts({int page = 1}) async {
    final response = await _client.get('/posts', queryParameters: {'page': page});
    final data = response.data['data'];
    return (data['data'] as List).map((e) => PostModel.fromJson(e)).toList();
  }

  Future<PostModel> createPost({String? content, String? styleTags}) async {
    final formData = FormData.fromMap({
      if (content != null) 'content': content, // ignore: use_null_aware_elements
      if (styleTags != null) 'style_tags': styleTags, // ignore: use_null_aware_elements
    });
    final response = await _client.post('/posts', data: formData);
    return PostModel.fromJson(response.data['data']);
  }

  Future<void> deletePost(int postId) async {
    await _client.delete('/posts/$postId');
  }

  Future<Map<String, dynamic>> toggleLike(int postId) async {
    final response = await _client.post('/posts/$postId/like');
    return response.data;
  }

  Future<void> addComment(int postId, String comment) async {
    await _client.post('/posts/$postId/comment', data: {'comment': comment});
  }

  Future<void> toggleFollow(int userId) async {
    await _client.post('/users/$userId/follow');
  }

  Future<bool> isFollowing(int userId) async {
    return false;
  }
}
