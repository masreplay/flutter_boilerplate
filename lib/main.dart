import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
  AsyncSnapshot<List<Post>> _snapshot = AsyncSnapshot.nothing();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _snapshot = AsyncSnapshot.waiting();
      });
      final result = await ApiClient().getPosts();
      setState(() {
        _snapshot = AsyncSnapshot.withData(ConnectionState.done, result);
      });
    } catch (e, s) {
      setState(() {
        _snapshot = AsyncSnapshot.withError(ConnectionState.done, e, s);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            switch (_snapshot.connectionState) {
              case ConnectionState.waiting:
                return const CircularProgressIndicator();
              case ConnectionState.done:
                if (_snapshot.hasError) {
                  return const Text('Error');
                }
                return Text('Posts ${_snapshot.data?.length}');
              case ConnectionState.none:
                return const Text('No internet connection');
              case ConnectionState.active:
                return const Text('Active');
            }
          },
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Center(
        child: Builder(
          builder: (context) {
            switch (_snapshot.connectionState) {
              case ConnectionState.waiting:
                return const CircularProgressIndicator();
              case ConnectionState.done:
                if (_snapshot.hasError) {
                  return const Text('Error');
                }
                return ListView.builder(
                  itemCount: _snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Text(_snapshot.data?[index].title ?? '');
                  },
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
