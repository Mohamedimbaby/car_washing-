import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/provider_cubit.dart';
import '../cubit/provider_state.dart';
import '../widgets/customer_card_widget.dart';
import 'customer_details_page.dart';

class ProviderCustomersPage extends StatefulWidget {
  const ProviderCustomersPage({super.key});

  @override
  State<ProviderCustomersPage> createState() => _ProviderCustomersPageState();
}

class _ProviderCustomersPageState extends State<ProviderCustomersPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ProviderCubit>().loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عملائي / My Customers'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن عميل / Search customer...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Customers List
          Expanded(
            child: BlocBuilder<ProviderCubit, ProviderState>(
              builder: (context, state) {
                if (state is ProviderLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProviderCustomersLoaded) {
                  final customers = state.customers.where((customer) {
                    if (_searchQuery.isEmpty) return true;
                    return customer.name.toLowerCase().contains(_searchQuery) ||
                        customer.email.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (customers.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ProviderCubit>().loadCustomers();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return CustomerCardWidget(
                          customer: customer,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomerDetailsPage(
                                  customer: customer,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 100,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا يوجد عملاء',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No customers yet',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
