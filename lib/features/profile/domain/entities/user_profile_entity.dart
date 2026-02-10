import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? profilePhoto;
  final String? address;
  final DateTime registrationDate;
  final String appId;

  const UserProfileEntity({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.profilePhoto,
    this.address,
    required this.registrationDate,
    required this.appId,
  });

  UserProfileEntity copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? profilePhoto,
    String? address,
    DateTime? registrationDate,
    String? appId,
  }) {
    return UserProfileEntity(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      address: address ?? this.address,
      registrationDate: registrationDate ?? this.registrationDate,
      appId: appId ?? this.appId,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        phone,
        profilePhoto,
        address,
        registrationDate,
        appId,
      ];
}
