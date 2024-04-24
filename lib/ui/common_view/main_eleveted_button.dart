import 'package:flutter/material.dart';

import '../../utils/dimens.dart';

class CustomElevatedButton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onPressed;
  final Widget child;
  final Color? borderColor;
  final Widget? prefixIcon;
  final double? prefixIconHeight;
  final double? prefixIconWidth;
  final double? prefixIconSpacing;
  final Widget? suffixIcon;
  final double? suffixIconSpacing;

  const CustomElevatedButton({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.color,
    this.gradient,
    this.onPressed,
    required this.child,
    this.borderColor,
    this.prefixIcon,
    this.prefixIconHeight,
    this.prefixIconWidth,
    this.prefixIconSpacing,
    this.suffixIcon,
    this.suffixIconSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: width,
          maxWidth: width,
          minHeight: height,
          maxHeight: height,
        ),
        child: Row(
          children: [
            Container(
              width: width,
              height: height,
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: averageScreenSize * 0.025,
                vertical: averageScreenSize * 0.01,
              ),
              decoration: BoxDecoration(
                color: color,
                gradient: gradient,
                borderRadius: BorderRadiusDirectional.circular(borderRadius),
                border: borderColor != null ? Border.all(color: borderColor!) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  prefixIcon != null
                      ? Expanded(
                          flex: prefixIcon == null ? 0 : 1,
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints.expand(width: prefixIconWidth, height: prefixIconHeight),
                            child: prefixIcon,
                          ),
                        )
                      : Container(),
                  prefixIconSpacing != null
                      ? Expanded(flex: 1, child: SizedBox(width: prefixIconSpacing!))
                      : const SizedBox(width: 0),
                  Expanded(
                    flex: 8,
                    child: Center(child: child),
                  ),
                  suffixIcon != null
                      ? Expanded(
                          flex: suffixIcon == null ? 0 : 1,
                          child: Center(
                            child: suffixIcon,
                          ),
                        )
                      : Container(),
                  suffixIconSpacing != null
                      ? Expanded(flex: 1, child: SizedBox(width: suffixIconSpacing!))
                      : const SizedBox(width: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
