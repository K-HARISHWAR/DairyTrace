import 'package:equatable/equatable.dart';

class FarmModel extends Equatable {
  final String id;
  final String farmCode;
  final String farmName;
  final String ownerName;
  final String? phone;
  final String village;
  final String? district;
  final String? state;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String collectionCentreId;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FarmModel({
    required this.id,
    required this.farmCode,
    required this.farmName,
    required this.ownerName,
    this.phone,
    required this.village,
    this.district,
    this.state,
    this.address,
    this.latitude,
    this.longitude,
    required this.collectionCentreId,
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'],
      farmCode: json['farm_code'],
      farmName: json['farm_name'],
      ownerName: json['owner_name'],
      phone: json['phone'],
      village: json['village'],
      district: json['district'],
      state: json['state'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      collectionCentreId: json['collection_centre_id'],
      isActive: json['is_active'] ?? true,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_code': farmCode,
      'farm_name': farmName,
      'owner_name': ownerName,
      'phone': phone,
      'village': village,
      'district': district,
      'state': state,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'collection_centre_id': collectionCentreId,
      'is_active': isActive,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  @override
  List<Object?> get props => [
        id,
        farmCode,
        farmName,
        ownerName,
        phone,
        village,
        district,
        state,
        address,
        latitude,
        longitude,
        collectionCentreId,
        isActive,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
