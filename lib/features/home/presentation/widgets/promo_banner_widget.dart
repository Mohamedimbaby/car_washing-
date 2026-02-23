import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import 'promo_card_widget.dart';
import 'dot_indicator_widget.dart';

class PromoBannerWidget extends StatelessWidget {
  const PromoBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();
        return Column(
          children: [
            SizedBox(
              height: 110,
              child: PageView.builder(
                itemCount: state.promos.length,
                onPageChanged: (i) =>
                    context.read<HomeCubit>().updatePromoIndex(i),
                itemBuilder: (context, index) => PromoCardWidget(
                  promo: state.promos[index],
                ),
              ),
            ),
            const SizedBox(height: 8),
            DotIndicatorWidget(
              count: state.promos.length,
              active: state.activePromoIndex,
            ),
          ],
        );
      },
    );
  }
}
