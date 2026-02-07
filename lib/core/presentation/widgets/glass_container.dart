import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const GlassContainer({
    super.key,
    this.width,
    this.height,
    required this.child,
    this.blur = 15,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadiusValue = borderRadius ?? BorderRadius.circular(20);
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadiusValue,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (color ?? AppColors.glassWhite).withOpacity(opacity),
              borderRadius: borderRadiusValue,
              border: Border.all(
                color: AppColors.glassWhite.withOpacity(0.1),
                width: 1.0,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (color ?? AppColors.glassWhite).withOpacity(opacity + 0.05),
                  (color ?? AppColors.glassWhite).withOpacity(opacity),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
