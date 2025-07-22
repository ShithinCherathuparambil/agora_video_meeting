import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum ButtonType { primary, secondary, danger, outline }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkGray),
                ),
              )
            : _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    return Text(text);
  }

  ButtonStyle _getButtonStyle() {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryYellow,
          foregroundColor: AppTheme.darkGray,
          elevation: 2,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightGray,
          foregroundColor: AppTheme.darkGray,
          elevation: 1,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case ButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.red,
          foregroundColor: AppTheme.white,
          elevation: 2,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case ButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryYellow,
          side: const BorderSide(color: AppTheme.primaryYellow, width: 2),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
    }
  }
}
