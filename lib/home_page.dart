import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/api_client.dart';
import 'package:flutter_boilerplate/async_snapshot_extension.dart';

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
        title: _snapshot.when(
          idle: () => null,
          loading: () => null,
          data: (data) {
            return Text('Posts ${data.length}');
          },
          error: (error, stackTrace) {
            return const Text('No internet connection');
          },
        ),

        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Center(
        child: _snapshot.when(
          idle: () => SizedBox.shrink(),
          loading: () => const CircularProgressIndicator(),
          data: (data) {
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Text(_snapshot.data?[index].title ?? '');
              },
            );
          },
          error: (error, stackTrace) {
            return const Text('Error');
          },
        ),
      ),
    );
  }
}
