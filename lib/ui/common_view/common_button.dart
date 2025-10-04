import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/colors.dart';
import '../../utils/dimens.dart';

class CustomButton extends StatelessWidget {
  final Widget? child;
  final String? text;

  final double width;
  final double height;
  final Function()? onPressed;
  final EdgeInsetsGeometry? padding;

  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? borderRadius;
  final double? prefixIconSpacing;
  final double? suffixIconSpacing;
  final double? splashColorOpacity;
  final bool isLoading;

  final Color? btnColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? margin;

  const CustomButton({
    super.key,
    this.text,
    this.child,
    required this.width,
    required this.height,
    this.borderRadius,
    this.btnColor = violet100,
    this.onPressed,
    this.borderColor,
    this.prefixIcon,
    this.prefixIconSpacing,
    this.suffixIcon,
    this.suffixIconSpacing,
    this.padding,
    this.margin,
    this.isLoading = false,
    this.splashColorOpacity,
  })  : assert(
          (text != null || child != null),
          'There is need a one type of content',
        ),
        assert(
          (text == null || child == null),
          'Cannot provide both text and child',
        );

  @override
  Widget build(BuildContext context) {
    BorderRadius btnRadius = BorderRadius.circular(borderRadius ?? averageScreenSize * 0.03);

    EdgeInsetsGeometry btnMargin = margin ?? EdgeInsetsDirectional.zero;

    EdgeInsetsGeometry btnPadding = padding ??
        EdgeInsetsDirectional.symmetric(
          horizontal: averageScreenSize * 0.025,
          vertical: averageScreenSize * 0.01,
        );

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: width, maxWidth: width, minHeight: height, maxHeight: height),
      child: ClipRRect(
        borderRadius: btnRadius,
        child: Material(
          color: isLoading ? btnColor?.withOpacity(splashColorOpacity ?? 0.5) : btnColor,
          type: MaterialType.button,
          animationDuration: const Duration(milliseconds: 500),
          borderRadius: btnRadius,
          child: InkWell(
            onTap: () => isLoading ? null : onPressed?.call(),
            splashColor: btnColor?.withOpacity(splashColorOpacity ?? 0.3),
            borderRadius: btnRadius,
            child: Container(
              margin: btnMargin,
              padding: btnPadding,
              decoration: BoxDecoration(
                borderRadius: btnRadius,
                border: Border.all(color: borderColor ?? Colors.transparent),
              ),
              child: isLoading
                  ? Container(
                      height: height,
                      width: screenWidth * 0.1,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        strokeCap: StrokeCap.round,
                        color: white100,
                        strokeWidth: averageScreenSize * 0.0075,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (prefixIcon != null)
                          Container(
                            margin: EdgeInsetsDirectional.only(end: prefixIconSpacing ?? (screenWidth * 0.02)),
                            child: prefixIcon,
                          ),
                        Expanded(
                          flex: 0,
                          child: (text ?? '').isNotEmpty
                              ? Text(
                                  text!,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: white80,
                                    fontWeight: FontWeight.w600,
                                    fontSize: averageScreenSize * 0.025,
                                  ),
                                )
                              : Center(child: child),
                        ),
                        if (suffixIcon != null)
                          Container(
                            margin: EdgeInsetsDirectional.only(start: suffixIconSpacing ?? (screenWidth * 0.02)),
                            child: suffixIcon,
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
