import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/data/mock_data_service.dart';
import '../../domain/entities/center_entity.dart';
import '../widgets/center_list_item.dart';
import '../widgets/centers_empty_state.dart';
import '../widgets/centers_search_app_bar.dart';

class SearchCentersPage extends StatefulWidget {
  const SearchCentersPage({super.key});

  @override
  State<SearchCentersPage> createState() => _SearchCentersPageState();
}

class _SearchCentersPageState extends State<SearchCentersPage> {
  final _searchController = TextEditingController();
  List<CenterEntity> _filtered = MockDataService.centers;

  void _handleSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = MockDataService.centers;
      } else {
        _filtered = MockDataService.centers
            .where(
              (c) =>
                  c.name.toLowerCase().contains(query.toLowerCase()) ||
                  c.address.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          CentersSearchAppBar(
            controller: _searchController,
            onChanged: _handleSearch,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: _filtered.isEmpty
                ? const SliverFillRemaining(
                    child: CentersEmptyState(),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          CenterListItem(center: _filtered[index]),
                      childCount: _filtered.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
