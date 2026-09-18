import 'dart:async';

import 'package:flutter/material.dart';

import 'package:secure_document_manager/core/constants/app_colors.dart';
import 'package:secure_document_manager/features/auth/data/services/auth_api_service.dart';

import '../widgets/auth_button.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/verification_code_field.dart';
import 'login_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;
  final DateTime expiresAt;

  const VerificationCodeScreen({
    super.key,
    required this.email,
    required this.expiresAt,
  });

  @override
  State<VerificationCodeScreen> createState() =>
      _VerificationCodeScreenState();
}

class _VerificationCodeScreenState
    extends State<VerificationCodeScreen> {
  final TextEditingController _codeController =
      TextEditingController();

  final AuthApiService _authApiService = AuthApiService();

  Timer? _countdownTimer;

  late Duration _remainingTime;

  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();

    _remainingTime =
        widget.expiresAt.difference(DateTime.now());

    if (_remainingTime.isNegative) {
      _remainingTime = Duration.zero;
    }

    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        final remaining =
            widget.expiresAt.difference(DateTime.now());

        if (remaining.isNegative ||
            remaining == Duration.zero) {
          _countdownTimer?.cancel();

          if (mounted) {
            setState(() {
              _remainingTime = Duration.zero;
            });
          }

          return;
        }

        if (mounted) {
          setState(() {
            _remainingTime = remaining;
          });
        }
      },
    );
  }

  String get _formattedTime {
    final minutes =
        _remainingTime.inMinutes.toString().padLeft(2, '0');

    final seconds =
        (_remainingTime.inSeconds % 60)
            .toString()
            .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  bool get _isCodeComplete {
    return _codeController.text.length == 6;
  }

  bool get _isExpired {
    return _remainingTime == Duration.zero;
  }

  Future<void> _verifyCode() async {
    if (!_isCodeComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the 6-digit verification code.',
          ),
        ),
      );
      return;
    }

    if (_isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This verification code has expired. Please request a new one.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authApiService.verifyEmailCode(
        email: widget.email,
        verificationCode: _codeController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email verified successfully!',
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification failed: $e',
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

  Future<void> _resendCode() async {
    if (_isResending) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      final newExpiresAt =
          await _authApiService.resendVerificationCode(
        email: widget.email,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _remainingTime =
            newExpiresAt.difference(DateTime.now());

        if (_remainingTime.isNegative) {
          _remainingTime = Duration.zero;
        }
      });

      _codeController.clear();

      _startCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A new verification code has been sent.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to resend code: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _goBackToSignup() {
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
                  child: _buildVerificationCard(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AuthHeader(
            title: 'Verify Your Email',
            subtitle:
                'We sent a verification code to your email address.',
          ),

          const SizedBox(height: 18),

          Text(
            widget.email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.purple,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Enter the 6-digit code',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          VerificationCodeField(
            controller: _codeController,
            onChanged: (_) {
              setState(() {});
            },
          ),

          const SizedBox(height: 20),

          Text(
            _isExpired
                ? 'Code expired'
                : 'Code expires in $_formattedTime',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isExpired
                  ? AppColors.pink
                  : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 28),

          AuthButton(
            text: 'Verify Email',
            onPressed: _isCodeComplete && !_isExpired
                ? _verifyCode
                : null,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 22),

          AuthFooter(
            message: "Didn't receive the code?",
            actionText:
                _isResending ? 'Sending...' : 'Resend',
            onActionPressed:
                _isResending ? null : _resendCode,
          ),

          const SizedBox(height: 16),

          TextButton(
            onPressed: _goBackToSignup,
            child: const Text(
              'Back to Sign Up',
              style: TextStyle(
                color: AppColors.purple,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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

