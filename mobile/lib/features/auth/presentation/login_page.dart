import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data_auth_service.dart';
import '../../directory/presentation/directory_illustration.dart';

/// Ã‰cran de connexion Peopleo.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ContrÃ´leurs utilisÃ©s pour lire le contenu des champs de saisie.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Vrai lorsque le mot de passe doit rester masquÃ©.
  bool hidePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    // LibÃ¨re les ressources des contrÃ´leurs quand l'Ã©cran est dÃ©truit.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Affiche un retour temporaire en bas de l'Ã©cran.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // VÃ©rifie que les champs sont remplis. La connexion serveur reste Ã  faire.
  Future<void> _signIn() async {
    final email = emailController.text.trim();
    if (email.isEmpty || passwordController.text.isEmpty) {
      _showMessage('Please complete both fields.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showMessage('Please enter a valid email address.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await AuthService.login(email, passwordController.text);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/contacts', (_) => false);
    } catch (e) {
      if (mounted) _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Adapte la hauteur au tÃ©lÃ©phone et permet de faire dÃ©filer l'Ã©cran.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 34),
                  // En-tÃªte avec l'icÃ´ne et le nom de l'application.
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: neumorphicDecoration(radius: 50),
                          child: const Icon(
                            Icons.people_alt_rounded,
                            size: 43,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(width: 18),
                        const Text(
                          'PEOPLEO',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2.5,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  // Illustration dÃ©corative du rÃ©pertoire de contacts.
                  const DirectoryIllustration(),
                  const SizedBox(height: 36),
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 43,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Let's get started",
                    style: TextStyle(fontSize: 22, color: AppColors.text),
                  ),
                  const SizedBox(height: 38),
                  // Champ e-mail, contrÃ´lÃ© par emailController.
                  _inputField(
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(
                        hintText: 'Email address',
                        hintStyle: TextStyle(color: Color(0xFF9AA1AF)),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.navy,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 19),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Champ mot de passe avec bouton pour afficher/masquer le texte.
                  _inputField(
                    child: TextField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Color(0xFF9AA1AF)),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.navy,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            // setState reconstruit l'Ã©cran avec le nouvel Ã©tat.
                            setState(() => hidePassword = !hidePassword);
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.navy,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 19,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 38),
                  // Le bouton lance la validation provisoire du formulaire.
                  Center(
                    child: Container(
                      width: 230,
                      height: 58,
                      decoration: neumorphicDecoration(radius: 35),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(35),
                          onTap: _isLoading ? null : _signIn,
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.navy,
                                    ),
                                  )
                                : const Text(
                                    'SIGN IN',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.text,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // L'inscription n'est pas encore implÃ©mentÃ©e : un message l'indique.
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/signup'),
                      child: const Text(
                        "Don't have an account? Click here",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Enveloppe un champ avec la hauteur et le style communs aux entrÃ©es.
  Widget _inputField({required Widget child}) {
    return Container(
      height: 62,
      decoration: neumorphicDecoration(radius: 30),
      child: child,
    );
  }
}
