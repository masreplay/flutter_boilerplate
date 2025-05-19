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

  // is refreshing
  bool get isRefreshing => value.connectionState == ConnectionState.waiting;

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
    if (isRefreshable && !isRefreshing) {
      return guard(_future!);
    }

    return Future.value();
  }
}

extension AsyncSnapshotExtension<T> on AsyncSnapshot<T> {
  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object? error, StackTrace? stackTrace) error,
  }) {
    return switch (connectionState) {
      ConnectionState.waiting || ConnectionState.active => loading(),
      ConnectionState.done =>
        hasError ? error(this.error, stackTrace) : data(this.data as T),
      ConnectionState.none => idle(),
    };
  }
}
