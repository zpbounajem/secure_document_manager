import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_document_manager/core/constants/app_colors.dart';
import 'package:secure_document_manager/features/auth/providers/user_provider.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Row(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: userProvider.user?.profileImage != null &&
                            userProvider.user!.profileImage!.isNotEmpty
                        ? Image.network(
                            userProvider.user!.profileImage!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: const Color(0xFFE2E8F0),
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 24,
                                  color: Color(0xFF64748B),
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: const Color(0xFFE2E8F0),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 24,
                              color: Color(0xFF64748B),
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Hello,',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.black,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userProvider.user?.fullName ?? 'User',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.black,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _HeaderButton(
              icon: Icons.notifications_none_rounded,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _HeaderButton(
              icon: Icons.calendar_today_outlined,
              onTap: () {},
            ),
          ],
        );
      },
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 26,
          color: AppColors.black,
        ),
      ),
    );
  }
}