import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Real-time validation states
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateFirstName(String value) {
    setState(() {
      final l10n = AppLocalizations.of(context)!;
      _firstNameError = Validators.validateRequired(value, l10n.pleaseEnterFirstName);
    });
  }

  void _validateLastName(String value) {
    setState(() {
      final l10n = AppLocalizations.of(context)!;
      _lastNameError = Validators.validateRequired(value, l10n.pleaseEnterLastName);
    });
  }

  void _validateEmail(String value) {
    setState(() {
      final l10n = AppLocalizations.of(context)!;
      _emailError = Validators.validateEmail(
        value,
        l10n.pleaseEnterEmail,
        l10n.invalidEmail,
      );
    });
  }

  void _validatePhone(String value) {
    setState(() {
      final l10n = AppLocalizations.of(context)!;
      _phoneError = Validators.validatePhone(
        value,
        l10n.pleaseEnterPhone,
        l10n.invalidPhone,
      );
    });
  }

  void _validatePassword(String value) {
    setState(() {
      final l10n = AppLocalizations.of(context)!;
      _passwordError = Validators.validatePassword(
        value,
        l10n.pleaseEnterPassword,
        l10n.passwordMinLength,
      );
      // Re-validate confirm password when password changes
      if (_confirmPasswordController.text.isNotEmpty) {
        _confirmPasswordError = Validators.validatePasswordConfirm(
          _passwordController.text,
          _confirmPasswordController.text,
          l10n.pleaseConfirmPassword,
          l10n.passwordsDoNotMatch,
        );
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      final l10n = AppLocalizations.of(context)!;
      _confirmPasswordError = Validators.validatePasswordConfirm(
        _passwordController.text,
        value,
        l10n.pleaseConfirmPassword,
        l10n.passwordsDoNotMatch,
      );
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Combine first name and last name into full name
      final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      ref.read(authProvider.notifier).register(
            _emailController.text,
            fullName,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    // Listen for successful registration (user becomes not null)
    ref.listen(authProvider, (previous, next) {
      if (next.user != null && next.error == null) {
        // Navigate to dashboard or home on success
        // Assuming '/dashboard' or '/' is the home route
        // For now, we can pop if it was pushed, or go to home
        if (context.canPop()) {
           context.pop();
        } else {
           // Fallback if we can't pop (e.g. direct navigation)
           // context.go('/'); // Uncomment when routes are defined
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.register)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.register,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: l10n.firstName,
                    prefixIcon: const Icon(Icons.person),
                    errorText: _firstNameError,
                  ),
                  onChanged: _validateFirstName,
                  validator: (value) => Validators.validateRequired(
                    value,
                    l10n.pleaseEnterFirstName,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: l10n.lastName,
                    prefixIcon: const Icon(Icons.person_outline),
                    errorText: _lastNameError,
                  ),
                  onChanged: _validateLastName,
                  validator: (value) => Validators.validateRequired(
                    value,
                    l10n.pleaseEnterLastName,
                  ),
                ),
                const SizedBox(height: 16),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: const Icon(Icons.email),
                      errorText: _emailError,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: _validateEmail,
                    validator: (value) => Validators.validateEmail(
                      value,
                      l10n.pleaseEnterEmail,
                      l10n.invalidEmail,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: l10n.phone,
                      prefixIcon: const Icon(Icons.phone),
                      errorText: _phoneError,
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: _validatePhone,
                    validator: (value) => Validators.validatePhone(
                      value,
                      l10n.pleaseEnterPhone,
                      l10n.invalidPhone,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.lock),
                      errorText: _passwordError,
                    ),
                    obscureText: true,
                    onChanged: _validatePassword,
                    validator: (value) => Validators.validatePassword(
                      value,
                      l10n.pleaseEnterPassword,
                      l10n.passwordMinLength,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: l10n.confirmPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      errorText: _confirmPasswordError,
                    ),
                    obscureText: true,
                    onChanged: _validateConfirmPassword,
                    validator: (value) => Validators.validatePasswordConfirm(
                      _passwordController.text,
                      value,
                      l10n.pleaseConfirmPassword,
                      l10n.passwordsDoNotMatch,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      authState.error!.replaceFirst('Exception: ', ''),
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
