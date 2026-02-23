import 'package:flutter/material.dart';

class PromoCardWidget extends StatelessWidget {
  final Map<String, dynamic> promo;

  const PromoCardWidget({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    final colors = (promo['gradient'] as List<int>)
        .map((c) => Color(c))
        .toList();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(child: _PromoText(promo: promo)),
          const Icon(
            Icons.local_car_wash,
            color: Colors.white38,
            size: 64,
          ),
        ],
      ),
    );
  }
}

class _PromoText extends StatelessWidget {
  final Map<String, dynamic> promo;

  const _PromoText({required this.promo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            promo['badge'] as String,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          promo['title'] as String,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          promo['subtitle'] as String,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}
