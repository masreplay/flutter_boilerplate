import 'package:flutter/material.dart';

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
