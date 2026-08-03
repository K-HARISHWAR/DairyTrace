import 'package:equatable/equatable.dart';
import '../../../../core/enums/user_role.dart';

class ProfileModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final UserRole role;
  final String? collectionCentreId;
  final String? distributorOrganisationId;
  final bool isActive;

  const ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    this.collectionCentreId,
    this.distributorOrganisationId,
    this.isActive = true,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'],
      role: UserRole.fromString(json['role']),
      collectionCentreId: json['collection_centre_id'],
      distributorOrganisationId: json['distributor_organisation_id'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role.value,
      if (collectionCentreId != null)
        'collection_centre_id': collectionCentreId,
      if (distributorOrganisationId != null)
        'distributor_organisation_id': distributorOrganisationId,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    phone,
    role,
    collectionCentreId,
    distributorOrganisationId,
    isActive,
  ];
}
