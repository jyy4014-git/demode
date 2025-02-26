import 'package:flutter/material.dart';

class ResponsiveLayout {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;
  
  static double getResponsiveWidth(BuildContext context, double percentage) {
    return width(context) * percentage;
  }
  
  static double getResponsiveHeight(BuildContext context, double percentage) {
    return height(context) * percentage;
  }
}
