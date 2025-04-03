import 'package:flutter/material.dart';

class ScreenUtil {
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double scaledWidth(BuildContext context, double percent) =>
      width(context) * (percent / 100);

  static double scaledHeight(BuildContext context, double percent) =>
      height(context) * (percent / 100);

  static bool isMobile(BuildContext context) => width(context) < 600;

  static bool isTablet(BuildContext context) =>
      width(context) >= 600 && width(context) < 1024;

  static bool isDesktop(BuildContext context) => width(context) >= 1024;

  static double responsiveFontSize(BuildContext context, double baseSize) {
    if (isMobile(context)) return baseSize;
    if (isTablet(context)) return baseSize * 1.2;
    if (isDesktop(context)) return baseSize * 1.4;
    return baseSize;
  }
}
