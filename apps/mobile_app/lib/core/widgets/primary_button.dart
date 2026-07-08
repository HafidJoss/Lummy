import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? shadowColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.shadowColor,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.primaryContainer;
    final sColor = widget.shadowColor ?? AppColors.primary;
    
    // Si está deshabilitado, lo ponemos gris
    final effectiveBgColor = widget.onPressed == null ? AppColors.surfaceContainer : bgColor;
    final effectiveSColor = widget.onPressed == null ? AppColors.surfaceContainerLow : sColor;
    final effectiveTextColor = widget.onPressed == null ? AppColors.outline : Colors.white;

    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 56,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!_isPressed && widget.onPressed != null)
              BoxShadow(
                color: effectiveSColor,
                offset: const Offset(0, 4),
              )
          ],
        ),
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.text.toUpperCase(),
                      style: TextStyle(
                        color: effectiveTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (widget.icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(widget.icon, color: effectiveTextColor),
                    ]
                  ],
                ),
        ),
      ),
    );
  }
}
