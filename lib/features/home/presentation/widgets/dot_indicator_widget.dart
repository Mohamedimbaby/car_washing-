import 'package:flutter/material.dart';

class DotIndicatorWidget extends StatelessWidget {
  final int count;
  final int active;

  const DotIndicatorWidget({
    super.key,
    required this.count,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: i == active
                ? const Color(0xFF0B2447)
                : const Color(0xFFCDD9F0),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
