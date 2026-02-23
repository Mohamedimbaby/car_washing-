import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.userId,
    required super.name,
    required super.email,
    super.phone,
    super.profilePhoto,
    super.address,
    required super.registrationDate,
    required super.appId,
    required super.role,
    super.isEmailVerified = false,
    super.isPhoneVerified = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      userId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      profilePhoto: data['profilePhoto'],
      address: data['address'],
      registrationDate:
          (data['registrationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      appId: data['appId'] ?? '',
      role: data['role'] ?? 'customer',
      isEmailVerified: data['isEmailVerified'] ?? false,
      isPhoneVerified: data['isPhoneVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profilePhoto': profilePhoto,
      'address': address,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'appId': appId,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
