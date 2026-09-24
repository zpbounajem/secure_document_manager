import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:secure_document_manager/core/constants/app_colors.dart';
import 'package:secure_document_manager/features/auth/data/models/project_model.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const ProjectCard({
    super.key,
    required this.project,
  });

  double degreesToRadians(double degrees) => degrees * (math.pi / 180);

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final double progressValue = (project.progress.clamp(0, 100)) / 100;

    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ------------------------------------------------------------
          // BACK DECORATIVE LAYERS (Full Card Backdrops - Exact Target Match)
          // ------------------------------------------------------------
          
          // 1. Back Layer 1: Peeks out TOP-LEFT (Purple/Blue)
          _buildBackLayer(
            colors: const [
              Color(0xFF818CF8), // Soft Blue
              Color(0xFFC084FC), // Soft Purple
            ],
            offset: const Offset(-6, -3),
            rotationDegrees: -5,
          ),

          // 2. Back Layer 2: Peeks out BOTTOM-RIGHT (Cyan/Yellow)
          _buildBackLayer(
            colors: const [
              Color(0xFFA5F3FC), // Light Cyan
              Color(0xFFFDE047), // Soft Yellow
            ],
            offset: const Offset(6, 3),
            rotationDegrees: 5,
          ),

        

          // ------------------------------------------------------------
          // MAIN CARD
          // ------------------------------------------------------------

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.pink2,
                    AppColors.pink3,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  children: [
                    // DECORATIVE CIRCLES & SHAPES
                    Positioned(
                      top: -45,
                      left: -30,
                      child: _decorativeCircle(
                        size: 125,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: -35,
                      child: _decorativeCircle(
                        size: 110,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                    Positioned(
                      bottom: -55,
                      left: 75,
                      child: _decorativeCircle(
                        size: 135,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    Positioned(
                      bottom: 25,
                      right: -25,
                      child: Transform.rotate(
                        angle: -0.25,
                        child: Container(
                          width: 80,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),

                    // CARD CONTENT
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 18, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  project.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 17),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${project.progress}%',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.90),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: 7,
                              child: LinearProgressIndicator(
                                value: progressValue,
                                backgroundColor: Colors.white.withValues(alpha: 0.22),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _infoItem(
                                icon: Icons.description_outlined,
                                text: project.document.toString(),
                              ),
                              const SizedBox(width: 22),
                              _infoItem(
                                icon: Icons.chat_bubble_outline,
                                text: project.comment.toString(),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildAvatars(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: AppColors.pink,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${_monthName(project.date.month)} ${project.date.day}, ${project.date.year}',
                                      style: TextStyle(
                                        color: AppColors.pink,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for back layers using Positioned.fill
  Widget _buildBackLayer({
    required List<Color> colors,
    required Offset offset,
    required double rotationDegrees,
  }) {
    return Positioned.fill(
      child: Transform.translate(
        offset: offset,
        child: Transform.rotate(
          angle: degreesToRadians(rotationDegrees),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.72), size: 17),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _decorativeCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildAvatars() {
    return SizedBox(
      width: 82,
      height: 34,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _avatar(left: 0, color: const Color(0xFF8C8C8C)),
          _avatar(left: 21, color: const Color(0xFFD1A07F)),
          _avatar(left: 42, color: const Color(0xFF4D8B72)),
        ],
      ),
    );
  }

  Widget _avatar({required double left, required Color color}) {
    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.person, size: 18, color: Colors.white70),
      ),
    );
  }
}