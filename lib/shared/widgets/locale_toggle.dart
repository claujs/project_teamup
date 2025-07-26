import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/locale_provider.dart';

class LocaleToggle extends ConsumerWidget {
  const LocaleToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeProvider);

    return IconButton(
      icon: Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
      onPressed: () {
        final newLocale = localeState == const Locale('pt', 'BR')
            ? const Locale('en', 'US')
            : const Locale('pt', 'BR');
        ref.read(localeProvider.notifier).changeLocale(newLocale);
      },
    );
  }
}
