import 'package:flutter/material.dart';
import 'package:foodie_customer/constants.dart';

class Indicator extends StatelessWidget {
  Indicator({
    this.controller,
    this.itemCount = 0,
  }) : assert(controller != null);

  /// PageView Controller
  final PageController? controller;

  /// Number of indicators
  final int itemCount;

  /// Ordinary colours
  final Color normalColor = const Color(0xffD9D9D9);

  /// Selected color
  final Color selectedColor = Color(COLOR_PRIMARY);

  /// Size of points
  final double size = 8.0;

  /// Spacing of points
  final double spacing = 4.0;

  /// Point Widget
  Widget _buildIndicator(int index, int pageCount, double dotSize, double spacing) {
    // Is the current page selected?
    bool isCurrentPageSelected = index == (controller!.page != null ? controller!.page!.round() % pageCount : 0);

    return SizedBox(
      height: size,
      width: size + (2 * spacing),
      child: Center(
        child: Material(
          color: isCurrentPageSelected ? selectedColor : normalColor,
          type: MaterialType.circle,
          child: SizedBox(
            width: dotSize,
            height: dotSize,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount, (int index) {
        return _buildIndicator(index, itemCount, size, spacing);
      }),
    );
  }
}
