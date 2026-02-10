import 'package:equatable/equatable.dart';

class BrandingConfigEntity extends Equatable {
  final String id;
  final String tenantId;
  final String appName;
  final String? splashImageUrl;
  final String? appIconUrl;
  final String primaryColor;
  final String secondaryColor;
  final String? accentColor;
  final Map<String, String>? customFonts;
  final Map<String, String>? customMessages;
  final DateTime updatedAt;

  const BrandingConfigEntity({
    required this.id,
    required this.tenantId,
    required this.appName,
    this.splashImageUrl,
    this.appIconUrl,
    required this.primaryColor,
    required this.secondaryColor,
    this.accentColor,
    this.customFonts,
    this.customMessages,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        tenantId,
        appName,
        splashImageUrl,
        appIconUrl,
        primaryColor,
        secondaryColor,
        accentColor,
        customFonts,
        customMessages,
        updatedAt,
      ];
}
