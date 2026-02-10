import '../../../../core/utils/typedef.dart';
import '../entities/tenant_entity.dart';
import '../entities/branding_config_entity.dart';

abstract class WhitelabelRepository {
  ResultFuture<List<TenantEntity>> getAllTenants();

  ResultFuture<TenantEntity> getTenantById(String id);

  ResultFuture<TenantEntity> createTenant({
    required String companyName,
    required String businessName,
    required String primaryColor,
    String? secondaryColor,
    String? logoUrl,
    String? appName,
    required SubscriptionPlan subscriptionPlan,
    required double commissionRate,
  });

  ResultVoid updateTenant({
    required String id,
    String? companyName,
    String? businessName,
    String? primaryColor,
    String? secondaryColor,
    String? logoUrl,
    String? appName,
    SubscriptionPlan? subscriptionPlan,
    double? commissionRate,
    bool? isActive,
  });

  ResultVoid deleteTenant(String id);

  ResultFuture<BrandingConfigEntity> getBrandingConfig(String tenantId);

  ResultVoid updateBrandingConfig({
    required String tenantId,
    required Map<String, dynamic> config,
  });
}
