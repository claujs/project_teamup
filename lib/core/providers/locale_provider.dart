import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import '../constants/app_strings.dart';
import '../providers.dart';
import '../storage/local_storage.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref.read(localStorageProvider));
});

class LocaleNotifier extends StateNotifier<Locale> {
  final LocalStorage _localStorage;
  static const String _localeKey = AppStrings.localeKey;

  LocaleNotifier(this._localStorage) : super(_getDeviceLocale()) {
    _loadLocale();
  }

  static Locale _getDeviceLocale() {
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    // Verifica se o idioma do dispositivo é suportado
    if (deviceLocale.languageCode == 'pt' ||
        deviceLocale.languageCode == 'en') {
      return deviceLocale;
    }
    // Se não for suportado, retorna português como padrão
    return const Locale('pt');
  }

  Future<void> _loadLocale() async {
    try {
      final savedLocale = await _localStorage.getString(_localeKey);
      if (savedLocale != null) {
        state = Locale(savedLocale);
      }
      // Se não há idioma salvo, mantém o idioma do dispositivo já definido no constructor
    } catch (e) {
      // If there's an error, keep the device locale
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
