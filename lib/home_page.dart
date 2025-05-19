import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/api_client.dart';
import 'package:flutter_boilerplate/async_snapshot_extension.dart';
import 'package:flutter_boilerplate/mutation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final mutation = Mutation<List<Post>>();

  @override
  void initState() {
    super.initState();
    mutation.guard(ApiClient().getPosts);
  }

  @override
  void dispose() {
    super.dispose();
    mutation.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder(
          valueListenable: mutation,
          builder: (context, value, child) {
            return value.when(
              idle: () => SizedBox(),
              loading: () => SizedBox(),
              data: (data) {
                return Text('Posts ${data.length}');
              },
              error: (error, stackTrace) {
                return const Text('No internet connection');
              },
            );
          },
        ),

        actions: [
          ValueListenableBuilder(
            valueListenable: mutation,
            builder: (context, value, child) {
              return mutation.isRefreshable
                  ? IconButton(
                    onPressed: mutation.refresh,
                    icon: const Icon(Icons.refresh),
                  )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Center(
        child: ValueListenableBuilder(
          valueListenable: mutation,
          builder: (context, value, child) {
            return value.when(
              idle: () => SizedBox.shrink(),
              loading: () => const CircularProgressIndicator(),
              data: (data) {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Text(data[index].title);
                  },
                );
              },
              error: (error, stackTrace) {
                return const Text('Error');
              },
            );
          },
        ),
      ),
    );
  }
}
