import 'package:dio/dio.dart';

class ApiClient {
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';
  final Dio _dio =
      Dio()
        ..interceptors.addAll([
          LogInterceptor(request: true, requestBody: true, responseBody: true),
        ]);

  Future<List<Post>> getPosts() async {
    // await Future.delayed(const Duration(seconds: 1));
    // if (Random().nextBool()) {
    //   throw Exception('Error');
    // }

    final response = await _dio.get('$_baseUrl/posts');
    final posts =
        (response.data as List<dynamic>)
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList();
    return posts;
  }
}

class Post {
  final int id;
  final String title;
  final String body;

  Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(id: json['id'], title: json['title'], body: json['body']);
  }
}
