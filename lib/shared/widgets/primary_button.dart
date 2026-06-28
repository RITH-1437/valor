import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final dynamic icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final bool isGlass;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.isGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: height ?? 56,
      decoration: isGlass
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.2), blurRadius: 10)],
            )
          : null,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isGlass ? null : (backgroundColor ?? const Color(0xFFD4AF37)),
            foregroundColor: foregroundColor ?? const Color(0xFF111111),
            disabledBackgroundColor: const Color(0xFF1F2937),
            disabledForegroundColor: const Color(0xFF6B7280),
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ).copyWith(
            backgroundColor: isGlass
                ? WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(WidgetState.disabled)) {
                        return const Color(0xFF1F2937);
                      }
                      return const Color(0xFFD4AF37);
                    },
                  )
                : null,
            foregroundColor: isGlass
                ? WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(WidgetState.disabled)) {
                        return const Color(0xFF6B7280);
                      }
                      return const Color(0xFF111111);
                    },
                  )
                : null,
            side: isGlass
                ? WidgetStateProperty.resolveWith<BorderSide?>(
                    (states) => const BorderSide(color: Colors.transparent),
                  )
                : null,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF111111),
                    ),
                  )
                : Row(
                    key: const ValueKey('content'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Builder(
                          builder: (context) {
                            if (icon is FaIconData) {
                              return FaIcon(icon, size: 18);
                            } else if (icon is IconData) {
                              return Icon(icon, size: 20);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(text),
                    ],
                  ),
          ),
        ),
    );
  }
}