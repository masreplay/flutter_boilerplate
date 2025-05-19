import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: ApiClient().getPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return const Text('Error');
            }

            return Text('Posts ${snapshot.data?.length}');
          },
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Post>>(
          future: ApiClient().getPosts(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const CircularProgressIndicator();
              case ConnectionState.done:
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return const Text('Error');
                }
                return ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder:
                      (context, index) =>
                          Text(snapshot.data?[index].title ?? ''),
                );

              case ConnectionState.none:
                return const Text('No internet connection');
              case ConnectionState.active:
                return const Text('Active');
            }
          },
        ),
      ),
    );
  }
}

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
