import 'package:equatable/equatable.dart';
import '../../../../core/enums/user_role.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'],
      role: UserRole.fromString(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role.value,
    };
  }

  @override
  List<Object?> get props => [id, email, fullName, phone, role];
}
