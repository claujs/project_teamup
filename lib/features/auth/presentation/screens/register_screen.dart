import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../l10n/app_localizations.dart';
import '../auth_notifier.dart';
import '../../../../core/utils/responsive_utils.dart';

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
            child: _RegisterForm(authState: authState),
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
                    child: _RegisterForm(authState: authState, isTablet: true),
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
                  child: _RegisterForm(authState: authState, isTablet: true),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends ConsumerStatefulWidget {
  final AuthState authState;
  final bool isTablet;

  const _RegisterForm({required this.authState, this.isTablet = false});

  @override
  ConsumerState<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authNotifierProvider.notifier)
          .register(
            _emailController.text,
            _fullNameController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    final uiState = ref.watch(uiStateProvider);
    final isTablet = widget.isTablet;
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isTablet) const Spacer(),

          Text(
            l10n.registerTitle,
            style: TextStyle(
              fontSize: isTablet ? 32 : 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isTablet ? 12 : 8),

          Text(
            l10n.registerSubtitle,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isTablet ? 40 : 32),

          // Email field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: l10n.emailLabel,
              hintText: l10n.emailHint,
              labelStyle: TextStyle(fontSize: isTablet ? 18 : 16),
            ),
            style: TextStyle(fontSize: isTablet ? 18 : 16),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) => FormValidators.email(value, context: context),
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),

          SizedBox(height: isTablet ? 24 : 16),

          // Full name field
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: l10n.fullNameLabel,
              hintText: l10n.fullNameHint,
              labelStyle: TextStyle(fontSize: isTablet ? 18 : 16),
            ),
            style: TextStyle(fontSize: isTablet ? 18 : 16),
            textInputAction: TextInputAction.next,
            validator: (value) =>
                FormValidators.fullName(value, context: context),
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),

          SizedBox(height: isTablet ? 24 : 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: l10n.passwordLabel,
              hintText: l10n.passwordHint,
              suffixIcon: IconButton(
                icon: Icon(
                  uiState.registerPasswordObscured
                      ? Icons.visibility
                      : Icons.visibility_off,
                  size: isTablet ? 24 : 20,
                ),
                onPressed: () {
                  ref
                      .read(uiStateProvider.notifier)
                      .toggleRegisterPasswordVisibility();
                },
              ),
              labelStyle: TextStyle(fontSize: isTablet ? 18 : 16),
            ),
            style: TextStyle(fontSize: isTablet ? 18 : 16),
            obscureText: uiState.registerPasswordObscured,
            textInputAction: TextInputAction.next,
            validator: (value) =>
                FormValidators.password(value, context: context),
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),

          SizedBox(height: isTablet ? 24 : 16),

          // Confirm password field
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: l10n.confirmPasswordLabel,
              hintText: l10n.confirmPasswordHint,
              suffixIcon: IconButton(
                icon: Icon(
                  uiState.registerConfirmPasswordObscured
                      ? Icons.visibility
                      : Icons.visibility_off,
                  size: isTablet ? 24 : 20,
                ),
                onPressed: () {
                  ref
                      .read(uiStateProvider.notifier)
                      .toggleRegisterConfirmPasswordVisibility();
                },
              ),
              labelStyle: TextStyle(fontSize: isTablet ? 18 : 16),
            ),
            style: TextStyle(fontSize: isTablet ? 18 : 16),
            obscureText: uiState.registerConfirmPasswordObscured,
            textInputAction: TextInputAction.done,
            validator: (value) => FormValidators.confirmPassword(
              value,
              _passwordController.text,
              context: context,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (_) => _handleRegister(),
          ),

          SizedBox(height: isTablet ? 32 : 24),

          // Login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.hasAccountQuestion,
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
              GestureDetector(
                onTap: !isLoading ? () => context.go('/login') : null,
                child: Text(
                  l10n.loginAction,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 24 : 16),

          // Register button
          SizedBox(
            height: isTablet ? 56 : 48,
            child: ElevatedButton(
              onPressed: !isLoading ? _handleRegister : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                ),
              ),
              child: isLoading
                  ? const LoadingWidget(size: 24)
                  : Text(
                      l10n.registerButton,
                      style: TextStyle(fontSize: isTablet ? 18 : 16),
                    ),
            ),
          ),

          if (!isTablet) const Spacer(flex: 2),
        ],
      ),
    );
  }
}
