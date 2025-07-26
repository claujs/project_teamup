import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../auth_notifier.dart';
import '../widgets/register_form.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        authenticated: (user) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.registrationSuccess),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home');
        },
        unauthenticated: () {},
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: ResponsiveBuilder(
          mobile: Padding(
            padding: const EdgeInsets.all(24.0),
            child: RegisterForm(authState: authState),
          ),
          tablet: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.isLandscape ? 500 : 400,
              ),
              child: Padding(
                padding: EdgeInsets.all(context.isLandscape ? 48.0 : 32.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: RegisterForm(authState: authState, isTablet: true),
                  ),
                ),
              ),
            ),
          ),
          desktop: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: RegisterForm(authState: authState, isTablet: true),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
