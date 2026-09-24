
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_document_manager/features/auth/presentation/widgets/profile/edit_profile_screen.dart';

import 'package:secure_document_manager/features/auth/providers/user_provider.dart';

import 'package:secure_document_manager/features/auth/presentation/widgets/profile/profile_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFEEECFA),
            Color(0xFFE4E7F8),
            Color(0xFFF6F5FC),
          ],
          stops: [
            0.0,
            0.35,
            0.70,
            1.0,
          ],
        ),
      ),
      child: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (userProvider.user == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    userProvider.error ??
                        'No user data available.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B6570),
                    ),
                  ),
                ),
              );
            }

            final user = userProvider.user!;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                24,
                20,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF17151B),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Manage your account information',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF77727D),
                    ),
                  ),

                  const SizedBox(height: 28),

                  ProfileHeader(
                    user: user,
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const EditProfileScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                      ),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF8068A8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
