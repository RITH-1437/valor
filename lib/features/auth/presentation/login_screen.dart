import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/valor_logo.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../core/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                    'Welcome to VALOR',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1, height: 1.1),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to access premium fashion',
                    style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    label: 'Email Address',
                    hint: 'you@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outlined, color: Colors.white70),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white70),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your password';
                      if (value.length < 8) return 'Password must be at least 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Sign In',
                    icon: Icons.arrow_forward_rounded,
                    isLoading: authState.status == AuthStatus.loading,
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        ref.read(authProvider.notifier).login(
                          _emailController.text.trim(),
                          _passwordController.text,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text("Don't have an account? ", style: TextStyle(fontSize: 14, color: Colors.white70)),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: const Text('Sign Up', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
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
