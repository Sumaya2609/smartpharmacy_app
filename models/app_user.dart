// lib/models/app_user.dart
class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String role;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
  });

  String get fullName => '$firstName $lastName';

  factory AppUser.fromDoc(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'address': address,
    'role': role,
  };
}
