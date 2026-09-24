import 'package:flutter/material.dart';

class RecentFileCard extends StatelessWidget {
  final String name;
  final String type;
  final String size;
  final String date;
  final IconData icon;

  const RecentFileCard({
    super.key,
    required this.name,
    required this.type,
    required this.size,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EAFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF9169C9),
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF242027),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$type  •  $size',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF89848F),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.more_horiz_rounded,
                size: 20,
                color: Color(0xFF77727D),
              ),
              const SizedBox(height: 7),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF9B969F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}