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
      registrationDate: (data['registrationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      appId: data['appId'] ?? '',
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
    };
  }
}
