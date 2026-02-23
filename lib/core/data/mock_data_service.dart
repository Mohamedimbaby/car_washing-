import '../../features/centers/domain/entities/center_entity.dart';
import 'mock_centers_data.dart';

class MockDataService {
  static List<CenterEntity> get centers => List.from(kMockCenters);

  static List<CenterEntity> get featuredCenters =>
      kMockCenters.where((c) => c.rating >= 4.6).toList();

  static List<Map<String, dynamic>> get promos => [
        {
          'title': 'First Wash Free!',
          'subtitle': 'New customers get their first wash on us',
          'badge': 'NEW USER',
          'gradient': [0xFF134074, 0xFF0099C8],
        },
        {
          'title': '20% Off Premium',
          'subtitle': 'Every Friday on Premium & Platinum packages',
          'badge': 'WEEKLY DEAL',
          'gradient': [0xFF7B1FA2, 0xFFE040FB],
        },
        {
          'title': 'Book 3, Get 1 Free',
          'subtitle': 'Valid on Standard package and above',
          'badge': 'BUNDLE',
          'gradient': [0xFF00796B, 0xFF00C897],
        },
      ];
}
