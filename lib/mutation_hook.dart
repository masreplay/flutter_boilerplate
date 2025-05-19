import 'package:flutter/widgets.dart';
import 'package:flutter_boilerplate/mutation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class _MutationHookCreator {
  const _MutationHookCreator();

  Mutation call<T>({AsyncSnapshot<T>? initialValue, List<Object?>? keys}) {
    return use(_MutationHook(initialValue, keys));
  }
}

const useMutation = _MutationHookCreator();

class _MutationHook<T> extends Hook<Mutation> {
  const _MutationHook(this.initialValue, [List<Object?>? keys])
    : super(keys: keys);

  final AsyncSnapshot<T>? initialValue;

  @override
  _MutationHookState createState() {
    return _MutationHookState();
  }
}

class _MutationHookState<T> extends HookState<Mutation, _MutationHook<T>> {
  late final _controller = Mutation(initialValue: hook.initialValue);

  @override
  Mutation build(BuildContext context) => _controller;

  @override
  void dispose() => _controller.dispose();

  @override
  String get debugLabel => 'useMutation';
}
