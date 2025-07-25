import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../l10n/app_localizations.dart';
import '../auth_notifier.dart';
import '../../../../core/utils/responsive_utils.dart';

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
        child: ResponsiveBuilder(
          mobile: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _LoginForm(
              authState: authState,
              uiState: uiState,
              credentialsState: credentialsState,
            ),
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
                    child: _LoginForm(
                      authState: authState,
                      uiState: uiState,
                      credentialsState: credentialsState,
                      isTablet: true,
                    ),
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
                  child: _LoginForm(
                    authState: authState,
                    uiState: uiState,
                    credentialsState: credentialsState,
                    isTablet: true,
                  ),
                ),
              ),
            ),
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
  final bool isTablet;

  const _LoginForm({
    required this.authState,
    required this.uiState,
    required this.credentialsState,
    this.isTablet = false,
  });

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preenche campos com credenciais salvas
    _emailController.text = widget.credentialsState.email;
    _passwordController.text = widget.credentialsState.password;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authNotifierProvider.notifier)
          .login(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    final isTablet = widget.isTablet;
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isTablet) const Spacer(),

          // Logo
          Container(
            width: isTablet ? 100 : 80,
            height: isTablet ? 100 : 80,
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
            child: Icon(
              Icons.people,
              size: isTablet ? 60 : 48,
              color: Colors.white,
            ),
          ),

          SizedBox(height: isTablet ? 40 : 32),

          Text(
            l10n.loginTitle,
            style: TextStyle(
              fontSize: isTablet ? 32 : 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isTablet ? 12 : 8),

          Text(
            l10n.loginSubtitle,
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
              labelText: l10n.email,
              labelStyle: TextStyle(fontSize: isTablet ? 18 : 16),
            ),
            style: TextStyle(fontSize: isTablet ? 18 : 16),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) => FormValidators.email(value, context: context),
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),

          SizedBox(height: isTablet ? 24 : 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: l10n.password,
              suffixIcon: IconButton(
                icon: Icon(
                  widget.uiState.loginPasswordObscured
                      ? Icons.visibility
                      : Icons.visibility_off,
                  size: isTablet ? 24 : 20,
                ),
                onPressed: () {
                  ref
                      .read(uiStateProvider.notifier)
                      .toggleLoginPasswordVisibility();
                },
              ),
              labelStyle: TextStyle(fontSize: isTablet ? 18 : 16),
            ),
            style: TextStyle(fontSize: isTablet ? 18 : 16),
            obscureText: widget.uiState.loginPasswordObscured,
            textInputAction: TextInputAction.done,
            validator: (value) =>
                FormValidators.password(value, context: context),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (_) => _handleLogin(),
          ),

          SizedBox(height: isTablet ? 32 : 24),

          // Login button
          SizedBox(
            height: isTablet ? 56 : 48,
            child: ElevatedButton(
              onPressed: !isLoading ? _handleLogin : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                ),
              ),
              child: isLoading
                  ? const LoadingWidget(size: 24)
                  : Text(
                      l10n.loginButton,
                      style: TextStyle(fontSize: isTablet ? 18 : 16),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Register link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.noAccountQuestion,
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: !isLoading ? () => context.go('/register') : null,
                child: Text(
                  l10n.createAccountAction,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (!isTablet) const Spacer(flex: 2),
        ],
      ),
    );
  }
}
