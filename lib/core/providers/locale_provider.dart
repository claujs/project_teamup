import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_strings.dart';
import '../providers.dart';
import '../storage/local_storage.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref.read(localStorageProvider));
});

class LocaleNotifier extends StateNotifier<Locale> {
  final LocalStorage _localStorage;
  static const String _localeKey = AppStrings.localeKey;

  LocaleNotifier(this._localStorage) : super(const Locale('pt')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final savedLocale = await _localStorage.getString(_localeKey);
      if (savedLocale != null) {
        state = Locale(savedLocale);
      }
    } catch (e) {
      // If there's an error, keep the default locale
    }
  }

  Future<void> changeLocale(Locale newLocale) async {
    state = newLocale;
    await _localStorage.saveString(_localeKey, newLocale.languageCode);
  }

  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'pt'
        ? const Locale('en')
        : const Locale('pt');
    await changeLocale(newLocale);
  }
}
