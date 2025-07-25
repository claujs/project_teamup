import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ui_state_provider.freezed.dart';

@freezed
class UIState with _$UIState {
  const factory UIState({
    @Default(true) bool loginPasswordObscured,
    @Default(true) bool registerPasswordObscured,
    @Default(true) bool registerConfirmPasswordObscured,
    @Default(0) int homeNavigationIndex,
    @Default({}) Set<String> expandedPostIds,
  }) = _UIState;
}

class UIStateNotifier extends StateNotifier<UIState> {
  UIStateNotifier() : super(const UIState());

  void toggleLoginPasswordVisibility() {
    state = state.copyWith(loginPasswordObscured: !state.loginPasswordObscured);
  }

  void toggleRegisterPasswordVisibility() {
    state = state.copyWith(
      registerPasswordObscured: !state.registerPasswordObscured,
    );
  }

  void toggleRegisterConfirmPasswordVisibility() {
    state = state.copyWith(
      registerConfirmPasswordObscured: !state.registerConfirmPasswordObscured,
    );
  }

  void setHomeNavigationIndex(int index) {
    state = state.copyWith(homeNavigationIndex: index);
  }

  void togglePostExpansion(String postId) {
    final expanded = Set<String>.from(state.expandedPostIds);
    if (expanded.contains(postId)) {
      expanded.remove(postId);
    } else {
      expanded.add(postId);
    }
    state = state.copyWith(expandedPostIds: expanded);
  }

  void collapsePost(String postId) {
    final expanded = Set<String>.from(state.expandedPostIds);
    expanded.remove(postId);
    state = state.copyWith(expandedPostIds: expanded);
  }

  void clearExpandedPosts() {
    state = state.copyWith(expandedPostIds: {});
  }
}

final uiStateProvider = StateNotifierProvider<UIStateNotifier, UIState>((ref) {
  return UIStateNotifier();
});
