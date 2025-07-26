import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentControllersNotifier
    extends StateNotifier<Map<String, TextEditingController>> {
  CommentControllersNotifier() : super({});

  final Map<String, TextEditingController> _controllers = {};

  TextEditingController getController(String postId) {
    if (_controllers.containsKey(postId)) {
      return _controllers[postId]!;
    }

    final controller = TextEditingController();
    _controllers[postId] = controller;

    Future.microtask(() {
      if (mounted) {
        state = Map.from(_controllers);
      }
    });

    return controller;
  }

  void removeController(String postId) {
    if (_controllers.containsKey(postId)) {
      _controllers[postId]?.dispose();
      _controllers.remove(postId);

      if (mounted) {
        state = Map.from(_controllers);
      }
    }
  }

  void clearController(String postId) {
    if (_controllers.containsKey(postId)) {
      _controllers[postId]?.clear();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }
}

final commentControllersProvider =
    StateNotifierProvider<
      CommentControllersNotifier,
      Map<String, TextEditingController>
    >((ref) {
      return CommentControllersNotifier();
    });
