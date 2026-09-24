
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:secure_document_manager/features/auth/providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _displayNameController;

  @override
  void initState() {
    super.initState();

    final user =
        context.read<UserProvider>().user;

    _firstNameController = TextEditingController(
      text: user?.firstName ?? '',
    );

    _lastNameController = TextEditingController(
      text: user?.lastName ?? '',
    );

    _displayNameController = TextEditingController(
      text: user?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider =
        context.watch<UserProvider>();

    final user = userProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No user data available.',
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                _buildTopBar(context),

                

                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF17151B),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Update your account information',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF77727D),
                  ),
                ),

                const SizedBox(height: 28),

                _buildProfileImage(user.profileImage),

                const SizedBox(height: 28),

                _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  hint: 'Enter your first name',
                  icon: Icons.person_outline_rounded,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  hint: 'Enter your last name',
                  icon: Icons.person_outline_rounded,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _displayNameController,
                  label: 'Display Name',
                  hint: 'Enter your display name',
                  icon: Icons.badge_outlined,
                ),

                const SizedBox(height: 16),

                _buildReadOnlyField(
                  label: 'Email',
                  value: user.email,
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 16),

                _buildReadOnlyField(
                  label: 'Role',
                  value: user.roleName,
                  icon: Icons.admin_panel_settings_outlined,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      _saveProfile(context);
                    },
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
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.04,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 22,
              color: Color(0xFF17151B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    final hasImage =
        imageUrl != null &&
        imageUrl.trim().isNotEmpty;

    return Center(
      child: Column(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE2E8F0),
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8068A8)
                      .withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: hasImage
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return const Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: Color(0xFF64748B),
                        );
                      },
                    )
                  : const Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: Color(0xFF64748B),
                    ),
            ),
          ),

          const SizedBox(height: 10),

          TextButton(
            onPressed: () {},
            child: const Text(
              'Change Photo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8068A8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3A3540),
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF8068A8),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFF8068A8),
                width: 1.2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3A3540),
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller:
              TextEditingController(text: value),
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF9E98A5),
            ),
            filled: true,
            fillColor:
                const Color(0xFFF1F0F5),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _saveProfile(BuildContext context) {
    final firstName =
        _firstNameController.text.trim();

    final lastName =
        _lastNameController.text.trim();

    final displayName =
        _displayNameController.text.trim();

    if (firstName.isEmpty) {
      _showMessage(
        context,
        'First name cannot be empty.',
      );
      return;
    }

    if (displayName.isEmpty) {
      _showMessage(
        context,
        'Display name cannot be empty.',
      );
      return;
    }

    // API update will be connected here.
    _showMessage(
      context,
      'Profile information is ready to be saved.',
    );
  }

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }
}
