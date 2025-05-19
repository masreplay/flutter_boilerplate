import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/api_client.dart';
import 'package:flutter_boilerplate/async_snapshot_extension.dart';

/// Keep track of current ui state, Loading | Data | Error | Idle
///
/// Example
/// ```dart
/// final mutation = ValueNotifier<AsyncSnapshot<List<Post>>>(
///    AsyncSnapshot.nothing(),
/// );
/// ```
class Mutation<T> extends ValueNotifier<AsyncSnapshot<T>> {
  Mutation() : super(AsyncSnapshot.nothing());
}

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
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      mutation.value = AsyncSnapshot.waiting();

      final result = await ApiClient().getPosts();

      mutation.value = AsyncSnapshot.withData(ConnectionState.done, result);
    } catch (e, s) {
      mutation.value = AsyncSnapshot.withError(ConnectionState.done, e, s);
    }
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
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
