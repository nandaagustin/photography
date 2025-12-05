class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String? phone;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
    };
  }
}
