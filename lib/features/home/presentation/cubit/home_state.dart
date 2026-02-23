import 'package:equatable/equatable.dart';
import '../../../centers/domain/entities/center_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<CenterEntity> featuredCenters;
  final List<Map<String, dynamic>> promos;
  final int activePromoIndex;

  const HomeLoaded({
    required this.featuredCenters,
    required this.promos,
    this.activePromoIndex = 0,
  });

  HomeLoaded copyWith({
    List<CenterEntity>? featuredCenters,
    List<Map<String, dynamic>>? promos,
    int? activePromoIndex,
  }) {
    return HomeLoaded(
      featuredCenters: featuredCenters ?? this.featuredCenters,
      promos: promos ?? this.promos,
      activePromoIndex: activePromoIndex ?? this.activePromoIndex,
    );
  }

  @override
  List<Object?> get props => [featuredCenters, promos, activePromoIndex];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
