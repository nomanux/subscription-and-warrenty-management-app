library;

class User {
  final String? name;
  final String? phoneNumber;
  final String? profileImagePath;

  User({
    this.name,
    this.phoneNumber,
    this.profileImagePath,
  });

  User copyWith({
    String? name,
    String? phoneNumber,
    String? profileImagePath,
  }) {
    return User(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phoneNumber': phoneNumber,
    'profileImagePath': profileImagePath,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    profileImagePath: json['profileImagePath'] as String?,
  );
}
