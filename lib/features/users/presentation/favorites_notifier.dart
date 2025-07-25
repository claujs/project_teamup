import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/storage/local_storage.dart';
import '../domain/entities/user.dart';

part 'favorites_notifier.freezed.dart';

@freezed
class FavoritesState with _$FavoritesState {
  const factory FavoritesState.initial() = _Initial;
  const factory FavoritesState.loading() = _Loading;
  const factory FavoritesState.loaded(List<User> favorites) = _Loaded;
  const factory FavoritesState.error(String message) = _Error;
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final LocalStorage _localStorage;
  static const String _favoritesKey = 'favorites_users';

  FavoritesNotifier(this._localStorage)
    : super(const FavoritesState.initial()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = const FavoritesState.loading();
    try {
      // Simula delay de API
      await Future.delayed(const Duration(seconds: 3));

      final cached = await _localStorage.getObject<List<dynamic>>(
        _favoritesKey,
      );
      final favorites =
          cached?.map((json) {
            final map = json is Map<String, dynamic>
                ? json
                : Map<String, dynamic>.from(json as Map);
            return User.fromJson(map);
          }).toList() ??
          [];
      state = FavoritesState.loaded(favorites);
    } catch (e) {
      state = FavoritesState.error(e.toString());
    }
  }

  Future<void> toggleFavorite(User user) async {
    state.maybeWhen(
      loaded: (favorites) {
        final newFavorites = List<User>.from(favorites);
        if (newFavorites.any((u) => u.id == user.id)) {
          newFavorites.removeWhere((u) => u.id == user.id);
        } else {
          newFavorites.add(user);
        }
        _localStorage.saveObject(
          _favoritesKey,
          newFavorites.map((u) => u.toJson()).toList(),
        );
        state = FavoritesState.loaded(newFavorites);
      },
      orElse: () {},
    );
  }
}
