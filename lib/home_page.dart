import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/api_client.dart';
import 'package:flutter_boilerplate/mutation.dart';
import 'package:flutter_boilerplate/mutation_hook.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final mutation = useMutation();

    return Scaffold(
      appBar: AppBar(
        title: mutation.value.when(
          idle: () => SizedBox(),
          loading: () => SizedBox(),
          data: (data) {
            return Text('Posts ${data.length}');
          },
          error: (error, stackTrace) {
            return const Text('No internet connection');
          },
        ),

        actions: [
          mutation.isRefreshable
              ? IconButton(
                onPressed: mutation.refresh,
                icon: const Icon(Icons.refresh),
              )
              : const SizedBox.shrink(),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: () async {
              final result = await mutation.guard(() {
                return ApiClient().addPost(
                  Post(id: 0, title: 'Test', body: 'Test'),
                );
              });

              result.when(
                idle: () {},
                loading: () {},
                data: (data) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Post added')));
                },
                error: (error, stackTrace) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error')));
                },
              );
            },
            child: const Text('Fetch'),
          ),
          Expanded(
            child: mutation.value.when(
              idle: () => SizedBox.shrink(),
              loading: () => Center(child: const CircularProgressIndicator()),
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
            ),
          ),
        ],
      ),
    );
  }
}
