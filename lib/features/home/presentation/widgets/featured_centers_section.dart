import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import 'featured_center_card.dart';
import 'section_header_widget.dart';

class FeaturedCentersSection extends StatelessWidget {
  const FeaturedCentersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeaderWidget(
                title: 'Top Rated Centers',
                actionLabel: 'See All',
                onActionTap: () =>
                    Navigator.pushNamed(context, '/search-centers'),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 220,
              child: state is HomeLoading
                  ? _ShimmerRow()
                  : state is HomeLoaded
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 20),
                          itemCount: state.featuredCenters.length,
                          itemBuilder: (context, index) {
                            return FeaturedCenterCard(
                              center: state.featuredCenters[index],
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/search-centers',
                              ),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      itemCount: 3,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.divider,
        highlightColor: AppColors.surfaceLight,
        child: Container(
          width: 200,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
