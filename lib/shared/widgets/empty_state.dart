import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = const SizedBox.shrink();
    if (icon is IconData) {
      if (icon is FaIconData) {
        iconWidget = FaIcon(icon as FaIconData, size: 40, color: AppTheme.gray);
      } else {
        iconWidget = Icon(icon as IconData, size: 44, color: AppTheme.gray);
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.darkGray,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.darkGray),
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppTheme.gray, fontSize: 14), textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: AppTheme.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
