
import 'package:flutter/material.dart';

import 'package:secure_document_manager/core/constants/app_colors.dart';
import 'package:secure_document_manager/features/auth/data/services/auth_api_service.dart';
import 'package:secure_document_manager/features/auth/data/services/auth_service.dart';

import '../screens/verification_code_screen.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';
import '../widgets/social_auth_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();
  final AuthApiService _authApiService = AuthApiService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }

    if (value.trim().length < 2) {
      return 'Please enter a valid name';
    }

    return null;
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
      return 'Please enter a password';
    }

    if (value.length < 6) {
      return 'Password must contain at least 6 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }
  Future<void> _signup() async {
  if (_isLoading) {
    return;
  }

  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (!_acceptTerms) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please agree to the Terms & Conditions and Privacy Policy.',
        ),
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final String fullName = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    debugPrint('STEP 1: Creating Firebase account...');
    debugPrint('Email: $email');

    final user = await _authService.signUp(
      fullName: fullName,
      email: email,
      password: password,
    );

    debugPrint(
      'STEP 1 SUCCESS: Firebase user = ${user?.uid}',
    );

    if (!mounted) {
      return;
    }

    if (user == null) {
      throw Exception(
        'Firebase account was not created.',
      );
    }

    debugPrint('STEP 2: Getting Firebase ID token...');

    final String? idToken =
        await _authService.getIdToken();

    if (idToken == null) {
      throw Exception(
        'Unable to get Firebase authentication token.',
      );
    }

    debugPrint('STEP 2 SUCCESS: Firebase ID token received.');

    debugPrint('STEP 3: Creating MySQL user...');

    await _authApiService.createUser(
      idToken: idToken,
      firstName: fullName,
      lastName: '',
      displayName: fullName,
    );

    debugPrint(
      'STEP 3 SUCCESS: MySQL user created.',
    );

    debugPrint(
      'STEP 4: Sending verification code...',
    );

    final expiresAt =
        await _authApiService.sendVerificationCode(
      email: email,
    );

    debugPrint(
      'STEP 4 SUCCESS: Verification code sent.',
    );

    if (!mounted) {
      return;
    }

    debugPrint(
      'STEP 5: Opening verification screen...',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationCodeScreen(
          email: email,
          expiresAt: expiresAt,
        ),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('SIGNUP ERROR: $e');
    debugPrint('STACK TRACE: $stackTrace');

    if (!mounted) {
      return;
    }

    final String message = e.toString().replaceFirst(
      'Exception: ',
      '',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
  
  void _signupWithGoogle() {
    // Google Authentication will be connected here.
  }

  void _goToLogin() {
    Navigator.pop(context);
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
                  child: _buildSignupCard(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupCard() {
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
              title: 'Create Account',
              subtitle:
                  'Create your account to securely manage your documents.',
            ),

            const SizedBox(height: 10),

            AuthTextField(
              label: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icons.person_outline_rounded,
              controller: _nameController,
              validator: _validateName,
            ),

            const SizedBox(height: 10),

            AuthTextField(
              label: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),

            const SizedBox(height: 10),

            PasswordField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onToggleVisibility: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              validator: _validatePassword,
            ),

            const SizedBox(height: 10),

            _buildConfirmPasswordField(),

            const SizedBox(height: 10),

            _buildTermsAndConditions(),

            const SizedBox(height: 20),

            AuthButton(
              text: 'Create Account',
              onPressed: _signup,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 12),

            const AuthDivider(),

            const SizedBox(height: 12),

            SocialAuthButton(
              text: 'Continue with Google',
              icon: const Text(
                'G',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: _signupWithGoogle,
            ),

            const SizedBox(height: 24),

            AuthFooter(
              message: 'Already have an account?',
              actionText: 'Login',
              onActionPressed: _goToLogin,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm Password',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          validator: _validateConfirmPassword,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'Confirm your password',
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.purple,
              size: 20,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword =
                      !_obscureConfirmPassword;
                });
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.purple,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.pink,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.pink,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            activeColor: AppColors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
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
          top: 150,
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
        color: color.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
    );
  }
}

