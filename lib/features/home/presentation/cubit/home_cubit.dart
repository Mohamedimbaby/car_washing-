import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/mock_data_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeInitial());

  Future<void> loadHomeData() async {
    emit(const HomeLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    emit(
      HomeLoaded(
        featuredCenters: MockDataService.featuredCenters,
        promos: MockDataService.promos,
      ),
    );
  }

  void updatePromoIndex(int index) {
    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(activePromoIndex: index));
    }
  }
}
