import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../l10n/app_localizations.dart';
import '../auth_notifier.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final uiState = ref.watch(uiStateProvider);
    final credentialsState = ref.watch(credentialsProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        authenticated: (user) {
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _LoginForm(
            authState: authState,
            uiState: uiState,
            credentialsState: credentialsState,
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  final AuthState authState;
  final UIState uiState;
  final CredentialsState credentialsState;

  const _LoginForm({
    required this.authState,
    required this.uiState,
    required this.credentialsState,
  });

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void didUpdateWidget(_LoginForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.credentialsState.email != oldWidget.credentialsState.email ||
        widget.credentialsState.password !=
            oldWidget.credentialsState.password) {
      _emailController.text = widget.credentialsState.email;
      _passwordController.text = widget.credentialsState.password;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authNotifierProvider.notifier)
          .login(_emailController.text, _passwordController.text);
    }
  }

  Future<void> _clearSavedCredentials() async {
    await ref.read(credentialsProvider.notifier).clearSavedCredentials();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.credentialsCleared),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: const Icon(Icons.people, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 32),

          Text(
            AppStrings.loginTitle,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.loginSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 48),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.email,
              hintText: AppStrings.emailHint,
              prefixIcon: const Icon(Icons.email_outlined),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.emailRequired;
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return AppStrings.emailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _passwordController,
            obscureText: widget.uiState.loginPasswordObscured,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.password,
              hintText: AppStrings.passwordHint,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  widget.uiState.loginPasswordObscured
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  ref
                      .read(uiStateProvider.notifier)
                      .toggleLoginPasswordVisibility();
                },
              ),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.passwordRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: widget.authState.when(
              initial: () => _buildLoginButton(),
              loading: () => const LoadingWidget(),
              authenticated: (user) => _buildLoginButton(),
              unauthenticated: () => _buildLoginButton(),
              error: (message) => _buildLoginButton(),
            ),
          ),
          const SizedBox(height: 16),

          if (widget.credentialsState.hasSavedCredentials)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.savedCredentials,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _clearSavedCredentials,
                  child: Icon(Icons.clear, size: 18, color: Colors.grey[600]),
                ),
              ],
            ),

          if (widget.credentialsState.hasSavedCredentials)
            const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.noAccountQuestion,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              GestureDetector(
                onTap: () => context.go('/register'),
                child: Text(
                  AppStrings.createAccountAction,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        AppLocalizations.of(context)!.loginButton,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
