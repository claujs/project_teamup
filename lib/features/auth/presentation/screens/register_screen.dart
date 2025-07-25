import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../auth_notifier.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final uiState = ref.watch(uiStateProvider);

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
          child: _RegisterForm(authState: authState, uiState: uiState),
        ),
      ),
    );
  }
}

class _RegisterForm extends ConsumerStatefulWidget {
  final AuthState authState;
  final UIState uiState;

  const _RegisterForm({required this.authState, required this.uiState});

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

  void _register() {
    if (_formKey.currentState!.validate()) {
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
            child: const Icon(Icons.person_add, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 32),

          Text(
            AppStrings.registerTitle,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.registerSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 48),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: AppStrings.emailLabel,
              hintText: AppStrings.emailHint,
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: FormValidators.email,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _fullNameController,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              labelText: AppStrings.fullNameLabel,
              hintText: AppStrings.fullNameHint,
              prefixIcon: Icon(Icons.person_outlined),
              border: OutlineInputBorder(),
            ),
            validator: FormValidators.fullName,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _passwordController,
            obscureText: widget.uiState.registerPasswordObscured,
            decoration: InputDecoration(
              labelText: AppStrings.passwordLabel,
              hintText: AppStrings.passwordHint,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  widget.uiState.registerPasswordObscured
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  ref
                      .read(uiStateProvider.notifier)
                      .toggleRegisterPasswordVisibility();
                },
              ),
              border: const OutlineInputBorder(),
            ),
            validator: FormValidators.password,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _confirmPasswordController,
            obscureText: widget.uiState.registerConfirmPasswordObscured,
            decoration: InputDecoration(
              labelText: AppStrings.confirmPasswordLabel,
              hintText: AppStrings.confirmPasswordHint,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  widget.uiState.registerConfirmPasswordObscured
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  ref
                      .read(uiStateProvider.notifier)
                      .toggleRegisterConfirmPasswordVisibility();
                },
              ),
              border: const OutlineInputBorder(),
            ),
            validator: (value) =>
                FormValidators.confirmPassword(value, _passwordController.text),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: widget.authState.when(
              initial: () => _buildRegisterButton(),
              loading: () => const LoadingWidget(),
              authenticated: (user) => _buildRegisterButton(),
              unauthenticated: () => _buildRegisterButton(),
              error: (message) => _buildRegisterButton(),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.hasAccountQuestion,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Text(
                  AppStrings.loginAction,
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

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _register,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        AppStrings.registerButton,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
