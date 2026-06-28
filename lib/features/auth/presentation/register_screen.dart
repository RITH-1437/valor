import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/valor_logo.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../core/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (!mounted) return;
      if (next.status == AuthStatus.authenticated) {
        context.go('/home');
      } else if (next.status == AuthStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.redAccent),
        );
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF111111),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Center(child: ValorLogo(size: 80)),
                  const SizedBox(height: 48),
                  const Text(
                    'Join VALOR',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1, height: 1.1),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Experience premium men's fashion",
                    style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'John Doe',
                    controller: _nameController,
                    prefixIcon: const FaIcon(FontAwesomeIcons.user, color: Colors.white70),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Email Address',
                    hint: 'you@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const FaIcon(FontAwesomeIcons.envelope, color: Colors.white70),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Create a strong password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const FaIcon(FontAwesomeIcons.lock, color: Colors.white70),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: FaIcon(_obscurePassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye, color: Colors.white70),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter a password';
                      if (value.length < 8) return 'Password must be at least 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    prefixIcon: const FaIcon(FontAwesomeIcons.lock, color: Colors.white70),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      child: FaIcon(_obscureConfirm ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye, color: Colors.white70),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please confirm your password';
                      if (value != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Create Account',
                    icon: FontAwesomeIcons.userPlus,
                    isLoading: authState.status == AuthStatus.loading,
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        ref.read(authProvider.notifier).register(
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? ', style: TextStyle(fontSize: 14, color: Colors.white70)),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text('Sign In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
