import '../../../../core/utils/typedef.dart';
import '../entities/review_entity.dart';

abstract class ReviewRepository {
  ResultFuture<ReviewEntity> createReview({
    required String bookingId,
    required String centerId,
    required int rating,
    String? comment,
    List<String>? photoUrls,
  });

  ResultFuture<List<ReviewEntity>> getCenterReviews(String centerId);

  ResultFuture<List<ReviewEntity>> getUserReviews();

  ResultFuture<ReviewEntity> getReviewById(String id);

  ResultVoid updateReview({
    required String id,
    int? rating,
    String? comment,
  });

  ResultVoid deleteReview(String id);
}
