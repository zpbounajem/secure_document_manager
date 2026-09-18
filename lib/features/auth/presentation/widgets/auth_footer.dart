import 'package:flutter/material.dart';

import 'package:secure_document_manager/core/constants/app_colors.dart';

// Footer widget for the authentication screens

class AuthFooter extends StatelessWidget {
  final String message;
  final String actionText;
  final VoidCallback? onActionPressed;

  const AuthFooter({
    super.key,
    required this.message,
    required this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        TextButton(
          onPressed: onActionPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.pink,
            padding: const EdgeInsets.only(left: 5),
          ),
          child: Text(
            actionText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}