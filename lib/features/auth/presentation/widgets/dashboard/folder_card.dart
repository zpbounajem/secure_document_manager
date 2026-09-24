import 'package:flutter/material.dart';

class FolderCard extends StatelessWidget {
  final String name;
  final int files;
  final double progress;
  final String type;

  const FolderCard({
    super.key,
    required this.name,
    required this.files,
    required this.progress,
    required this.type,
  });

  Color get backgroundColor {
    switch (type) {
      case 'green':
        return const Color(0xFFDDF7D7);
      case 'blue':
        return const Color(0xFFD5ECFF);
      case 'cyan':
        return const Color(0xFFD7F3F5);
      case 'purple':
        return const Color(0xFFE8D9FA);
      default:
        return const Color(0xFFEAEAEA);
    }
  }

  Color get folderColor {
    switch (type) {
      case 'green':
        return const Color(0xFF72D65C);
      case 'blue':
        return const Color(0xFF64B5ED);
      case 'cyan':
        return const Color(0xFF5ACED2);
      case 'purple':
        return const Color(0xFFAE76E6);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_rounded,
                size: 43,
                color: folderColor,
              ),
              const Spacer(),
              const Icon(
                Icons.more_horiz_rounded,
                size: 21,
                color: Color(0xFF55515A),
              ),
            ],
          ),

          const Spacer(),

          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF242027),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            '$files files',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF77727D),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withOpacity(0.7),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      folderColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF55515A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}