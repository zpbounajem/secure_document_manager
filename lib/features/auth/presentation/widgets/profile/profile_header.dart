
import 'package:flutter/material.dart';

import 'package:secure_document_manager/features/auth/data/models/user_model.dart';
import 'package:secure_document_manager/features/auth/presentation/widgets/profile/profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileAvatar(
            imageUrl: user.profileImage,
          ),

          const SizedBox(height: 14),

          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Color(0xFF17151B),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            user.email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF77727D),
            ),
          ),
        ],
      ),
    );
  }
}
