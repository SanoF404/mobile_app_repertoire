import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data_auth_service.dart';

/// Account creation screen. Registration is simulated until an auth service is
/// connected, matching the assignment's standalone UI flow.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unable to create account'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignUp() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmation = _confirmPasswordController.text;
    if ([
      firstName,
      lastName,
      email,
      password,
      confirmation,
    ].any((value) => value.isEmpty)) {
      _showError('Please complete all fields.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showError('Please enter a valid email address.');
      return;
    }
    if (password.length < 8) {
      _showError('Your password must contain at least 8 characters.');
      return;
    }
    if (password != confirmation) {
      _showError('The passwords do not match.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await AuthService.signup(email, password);
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/contacts', (_) => false);
      }
    } catch (e) {
      if (mounted) _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 36,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 58,
                    color: AppColors.navy,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Create your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _field(
                    controller: _firstNameController,
                    label: 'First name',
                    icon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 18),
                  _field(
                    controller: _lastNameController,
                    label: 'Last name',
                    icon: Icons.badge_outlined,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 18),
                  _field(
                    controller: _emailController,
                    label: 'Email address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 18),
                  _field(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 18),
                  _field(
                    controller: _confirmPasswordController,
                    label: 'Confirm password',
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirmation,
                    onToggleVisibility: () => setState(
                      () => _obscureConfirmation = !_obscureConfirmation,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("CREATE ACCOUNT"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('/login'),
                    child: const Text('Already have an account? Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      height: 62,
      decoration: neumorphicDecoration(radius: 30),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        style: const TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Color(0xFF9AA1AF)),
          prefixIcon: Icon(icon, color: AppColors.navy),
          suffixIcon: onToggleVisibility == null
              ? null
              : IconButton(
                  onPressed: onToggleVisibility,
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.navy,
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 19),
        ),
      ),
    );
  }
}
