import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/center_cubit.dart';
import '../cubit/center_state.dart';
import '../widgets/center_list_item.dart';

class SearchCentersPage extends StatefulWidget {
  const SearchCentersPage({super.key});

  @override
  State<SearchCentersPage> createState() => _SearchCentersPageState();
}

class _SearchCentersPageState extends State<SearchCentersPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNearby();
  }

  void _loadNearby() {
    // In a real app, get user's current location
    context.read<CenterCubit>().loadNearbyCenters(
          latitude: 37.7749,
          longitude: -122.4194,
        );
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      _loadNearby();
    } else {
      context.read<CenterCubit>().searchCenters(query: query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Car Wash Centers'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearch,
              decoration: InputDecoration(
                hintText: 'Search centers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadNearby();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<CenterCubit, CenterState>(
              builder: (context, state) {
                if (state is CenterLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CentersLoaded) {
                  if (state.centers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No centers found',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.centers.length,
                    itemBuilder: (context, index) {
                      return CenterListItem(center: state.centers[index]);
                    },
                  );
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
