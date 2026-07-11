enum UserRole {
  admin,
  collectionStaff,
  distributor,
  customer;

  factory UserRole.fromString(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'collection_staff':
        return UserRole.collectionStaff;
      case 'distributor':
        return UserRole.distributor;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.collectionStaff:
        return 'collection_staff';
      case UserRole.distributor:
        return 'distributor';
      case UserRole.customer:
        return 'customer';
    }
  }
}
