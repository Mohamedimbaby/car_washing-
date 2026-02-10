import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final String centerId;
  final int rating;
  final String? comment;
  final List<String>? photoUrls;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatarUrl;

  const ReviewEntity({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.centerId,
    required this.rating,
    this.comment,
    this.photoUrls,
    required this.createdAt,
    this.userName,
    this.userAvatarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        userId,
        centerId,
        rating,
        comment,
        photoUrls,
        createdAt,
        userName,
        userAvatarUrl,
      ];
}
