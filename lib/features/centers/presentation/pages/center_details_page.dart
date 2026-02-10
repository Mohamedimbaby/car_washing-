import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/center_entity.dart';
import '../cubit/center_cubit.dart';
import '../cubit/center_state.dart';
import '../widgets/center_info_section.dart';
import '../widgets/center_services_section.dart';

class CenterDetailsPage extends StatefulWidget {
  final String centerId;

  const CenterDetailsPage({
    super.key,
    required this.centerId,
  });

  @override
  State<CenterDetailsPage> createState() => _CenterDetailsPageState();
}

class _CenterDetailsPageState extends State<CenterDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<CenterCubit>().loadCenterDetails(widget.centerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CenterCubit, CenterState>(
        builder: (context, state) {
          if (state is CenterLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CenterDetailsLoaded) {
            return _buildDetails(state.center);
          } else if (state is CenterError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetails(CenterEntity center) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(center.name),
            background: center.logoUrl != null
                ? Image.network(center.logoUrl!, fit: BoxFit.cover)
                : Container(
                    color: AppColors.primary,
                    child: const Icon(
                      Icons.local_car_wash,
                      size: 80,
                      color: AppColors.white,
                    ),
                  ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CenterInfoSection(center: center),
              CenterServicesSection(center: center),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to booking
                    },
                    child: const Text('Book Now'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
