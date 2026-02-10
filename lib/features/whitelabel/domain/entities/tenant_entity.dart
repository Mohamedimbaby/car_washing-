import 'package:equatable/equatable.dart';

enum SubscriptionPlan { free, basic, premium, enterprise }

class TenantEntity extends Equatable {
  final String id;
  final String companyName;
  final String businessName;
  final String primaryColor;
  final String? secondaryColor;
  final String? logoUrl;
  final String? appName;
  final SubscriptionPlan subscriptionPlan;
  final double commissionRate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? subscriptionEndDate;

  const TenantEntity({
    required this.id,
    required this.companyName,
    required this.businessName,
    required this.primaryColor,
    this.secondaryColor,
    this.logoUrl,
    this.appName,
    required this.subscriptionPlan,
    required this.commissionRate,
    this.isActive = true,
    required this.createdAt,
    this.subscriptionEndDate,
  });

  @override
  List<Object?> get props => [
        id,
        companyName,
        businessName,
        primaryColor,
        secondaryColor,
        logoUrl,
        appName,
        subscriptionPlan,
        commissionRate,
        isActive,
        createdAt,
        subscriptionEndDate,
      ];
}
