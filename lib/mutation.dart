import 'package:flutter/material.dart';

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

  Future<T> Function()? _future;

  bool get isRefreshable => _future != null;

  Future<void> guard(Future<T> Function() futureCallback) async {
    try {
      value = AsyncSnapshot.waiting();

      final T result = await futureCallback();

      _future = futureCallback;

      value = AsyncSnapshot.withData(ConnectionState.done, result);
    } catch (e, s) {
      value = AsyncSnapshot.withError(ConnectionState.done, e, s);
    }
  }

  Future<void> refresh() {
    if (_future == null) {
      return Future.value();
    }

    return guard(_future!);
  }
}
