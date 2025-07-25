import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentControllersNotifier
    extends StateNotifier<Map<String, TextEditingController>> {
  CommentControllersNotifier() : super({});

  TextEditingController getController(String postId) {
    if (!state.containsKey(postId)) {
      state = {...state, postId: TextEditingController()};
    }
    return state[postId]!;
  }

  void removeController(String postId) {
    if (state.containsKey(postId)) {
      state[postId]?.dispose();
      final newState = Map<String, TextEditingController>.from(state);
      newState.remove(postId);
      state = newState;
    }
  }

  void clearController(String postId) {
    if (state.containsKey(postId)) {
      state[postId]?.clear();
    }
  }

  @override
  void dispose() {
    for (final controller in state.values) {
      controller.dispose();
    }
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
