import 'package:fitness_screen/core/app_colors.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key, this.onBack, this.onCalendar, this.avatar});

  final VoidCallback? onBack;
  final VoidCallback? onCalendar;
  final ImageProvider? avatar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CircleButton(
          icon: Icons.arrow_back,
          onTap: onBack ?? () => Navigator.maybePop(context),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CircleButton(
              icon: Icons.calendar_today_outlined,
              onTap: onCalendar,
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.peach,
              backgroundImage: avatar,
              child: avatar == null
                  ? const Icon(Icons.person, size: 20, color: AppColors.dark)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 18, color: AppColors.black),
        ),
      ),
    );
  }
}
