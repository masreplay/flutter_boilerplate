import 'package:flutter/widgets.dart';
import 'package:flutter_boilerplate/mutation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class _MutationHookCreator<T> {
  const _MutationHookCreator();

  Mutation<T> call({AsyncSnapshot<T>? initialValue, List<Object?>? keys}) {
    return use<Mutation<T>>(
      _MutationHook.fromValue(
        initialValue ?? AsyncSnapshot<T>.nothing(),
        keys: keys,
      ),
    );
  }

  Mutation<T> riverpod(MutationCallback<T> future, [List<Object?>? keys]) {
    return use(_MutationHook.riverpod(future, keys: keys));
  }
}

const useMutation = _MutationHookCreator();

class _MutationHook<T> extends Hook<Mutation<T>> {
  const _MutationHook.riverpod(
    MutationCallback<T> this.initialFuture, {
    super.keys,
  }) : initialValue = null;

  const _MutationHook.fromValue(
    AsyncSnapshot<T> this.initialValue, {
    super.keys,
  }) : initialFuture = null;

  final AsyncSnapshot<T>? initialValue;
  final MutationCallback<T>? initialFuture;

  @override
  _MutationHookState<T> createState() {
    return _MutationHookState<T>();
  }
}

class _MutationHookState<T> extends HookState<Mutation<T>, _MutationHook<T>> {
  late final Mutation<T> _controller = Mutation<T>(
    initialValue: hook.initialValue,
  )..addListener(_listener);

  @override
  Mutation<T> build(BuildContext context) => _controller;

  @override
  void initHook() {
    if (hook.initialFuture case final callback?) {
      _controller.guard(callback);
    }
  }

  @override
  void dispose() => _controller.dispose();

  void _listener() {
    setState(() {});
  }

  @override
  Object? get debugValue => _controller.value;

  @override
  String get debugLabel => 'useMutation';
}
