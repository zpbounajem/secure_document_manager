
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:secure_document_manager/core/constants/app_colors.dart';
import 'package:secure_document_manager/features/auth/data/services/auth_api_service.dart';
import 'package:secure_document_manager/features/auth/data/services/auth_service.dart';
import 'package:secure_document_manager/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:secure_document_manager/features/auth/presentation/screens/signup_screen.dart';

import '../widgets/auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';
import '../widgets/social_auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthApiService _authApiService = AuthApiService();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must contain at least 6 characters';
    }

    return null;
  }

  Future<void> _login() async {
    if (_isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (user == null) {
        throw Exception('Unable to log in.');
      }

      final String? idToken =
          await _authService.getIdToken();

      if (idToken == null) {
        throw Exception(
          'Unable to authenticate with the server.',
        );
      }

      final userData = await _authApiService.login(
        idToken: idToken,
      );

      if (!mounted) {
        return;
      }

      debugPrint(
        'LOGIN SUCCESS: $userData',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
        ),
      );

      // Dashboard navigation will be added here.
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint(
        'GOOGLE LOGIN: Starting Google Sign-In...',
      );

      final User? user =
          await _authService.signInWithGoogle();

      if (!mounted) {
        return;
      }

      if (user == null) {
        debugPrint(
          'GOOGLE LOGIN: User cancelled Google Sign-In.',
        );
        return;
      }

      debugPrint(
        'GOOGLE LOGIN: Firebase user = ${user.uid}',
      );

      final String? idToken =
          await _authService.getIdToken();

      if (idToken == null) {
        throw Exception(
          'Unable to get Firebase authentication token.',
        );
      }

      debugPrint(
        'GOOGLE LOGIN: Firebase ID token received.',
      );

      final userData = await _authApiService.login(
        idToken: idToken,
      );

      if (!mounted) {
        return;
      }

      debugPrint(
        'GOOGLE LOGIN SUCCESS: $userData',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google login successful!'),
        ),
      );

      // Dashboard navigation will be added here.
    } catch (e, stackTrace) {
      debugPrint(
        'GOOGLE LOGIN ERROR: $e',
      );

      debugPrint(
        'GOOGLE LOGIN STACK TRACE: $stackTrace',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ForgotPasswordScreen(),
      ),
    );
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SignupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            _buildDecorations(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 480,
                  ),
                  child: _buildLoginCard(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(
              alpha: 0.10,
            ),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthHeader(
              title: 'Welcome Back',
              subtitle:
                  'Sign in to access your secure documents.',
            ),

            const SizedBox(height: 32),

            AuthTextField(
              label: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              controller: _emailController,
              keyboardType:
                  TextInputType.emailAddress,
              validator: _validateEmail,
            ),

            const SizedBox(height: 20),

            PasswordField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onToggleVisibility: () {
                setState(() {
                  _obscurePassword =
                      !_obscurePassword;
                });
              },
              validator: _validatePassword,
            ),

            const SizedBox(height: 5),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _forgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor:
                      AppColors.purple,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            AuthButton(
              text: 'Login',
              onPressed: _login,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 28),

            const AuthDivider(),

            const SizedBox(height: 24),

            SocialAuthButton(
              text: 'Continue with Google',
              icon: const Text(
                'G',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: _loginWithGoogle,
            ),

            const SizedBox(height: 28),

            AuthFooter(
              message:
                  "Don't have an account?",
              actionText: 'Sign Up',
              onActionPressed: _goToRegister,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -70,
          right: -50,
          child: _pastelCircle(
            size: 190,
            color: AppColors.purple,
          ),
        ),
        Positioned(
          top: 130,
          left: -80,
          child: _pastelCircle(
            size: 150,
            color: AppColors.blue,
          ),
        ),
        Positioned(
          bottom: -80,
          right: -40,
          child: _pastelCircle(
            size: 180,
            color: AppColors.green,
          ),
        ),
        Positioned(
          bottom: 80,
          left: -50,
          child: _pastelCircle(
            size: 110,
            color: AppColors.yellow,
          ),
        ),
      ],
    );
  }

  Widget _pastelCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.35,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}
