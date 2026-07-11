import 'package:equatable/equatable.dart';

class FarmModel extends Equatable {
  final String id;
  final String farmerName;
  final String? phone;
  final String? address;
  final double? locationLat;
  final double? locationLng;

  const FarmModel({
    required this.id,
    required this.farmerName,
    this.phone,
    this.address,
    this.locationLat,
    this.locationLng,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'],
      farmerName: json['farmer_name'],
      phone: json['phone'],
      address: json['address'],
      locationLat: json['location_lat']?.toDouble(),
      locationLng: json['location_lng']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_name': farmerName,
      'phone': phone,
      'address': address,
      'location_lat': locationLat,
      'location_lng': locationLng,
    };
  }

  @override
  List<Object?> get props => [id, farmerName, phone, address, locationLat, locationLng];
}
