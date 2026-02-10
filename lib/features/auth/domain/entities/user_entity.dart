import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? phoneNumber;
  final String? fullName;
  final String? profileImage;
  final DateTime? createdAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  const UserEntity({
    required this.id,
    required this.email,
    this.phoneNumber,
    this.fullName,
    this.profileImage,
    required this.createdAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        phoneNumber,
        fullName,
        profileImage,
        createdAt,
        isEmailVerified,
        isPhoneVerified,
      ];
}
