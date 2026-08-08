class CentreModel {
  final String id;
  final String centreCode;
  final String name;
  final String? address;
  final String? village;
  final String? district;
  final String? state;
  final String? postalCode;
  final bool isActive;
  final DateTime createdAt;

  CentreModel({
    required this.id,
    required this.centreCode,
    required this.name,
    this.address,
    this.village,
    this.district,
    this.state,
    this.postalCode,
    required this.isActive,
    required this.createdAt,
  });

  factory CentreModel.fromJson(Map<String, dynamic> json) {
    return CentreModel(
      id: json['id'] as String,
      centreCode: json['centre_code'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      village: json['village'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
