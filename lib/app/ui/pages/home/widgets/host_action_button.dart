import 'package:flutter/material.dart';

class HostActionButton extends StatelessWidget {
  const HostActionButton({
    super.key,
    this.icon,          // opción A: IconData
    this.leading,       // opción B: cualquier widget (FaIcon, Lottie, Image)
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.glowColor = const Color(0xFF1E88E5),
  });

  final IconData? icon;
  final Widget? leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2128),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: glowColor.withOpacity(.75), width: 2),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(.35),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ] else if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.85),
                        fontSize: 13,
                        height: 1.2,
                      )),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(.9)),
          ],
        ),
      ),
    );
  }
}
