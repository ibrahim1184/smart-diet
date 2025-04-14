class UserModel {
  String? email;
  String? firstName;
  String? lastName;
  int? age;
  double? height;
  double? weight;
  double? waist;
  double? neck;
  double? hip;
  String? gender;
  final String? profileImageUrl;

  UserModel({
    this.email,
    this.firstName,
    this.lastName,
    this.age,
    this.height,
    this.weight,
    this.waist,
    this.neck,
    this.hip,
    this.gender,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      age: json['age'] is int
          ? json['age']
          : int.tryParse(json['age']?.toString() ?? ''),
      height: json['height'] is double
          ? json['height']
          : double.tryParse(json['height']?.toString() ?? ''),
      weight: json['weight'] is double
          ? json['weight']
          : double.tryParse(json['weight']?.toString() ?? ''),
      waist: json['waist'] is double
          ? json['waist']
          : double.tryParse(json['waist']?.toString() ?? ''),
      neck: json['neck'] is double
          ? json['neck']
          : double.tryParse(json['neck']?.toString() ?? ''),
      hip: json['hip'] is double
          ? json['hip']
          : double.tryParse(json['hip']?.toString() ?? ''),
      gender: json['gender']?.toString(),
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'height': height?.toString(),
      'weight': weight?.toString(),
      'waist': waist?.toString(),
      'neck': neck?.toString(),
      'hip': hip?.toString(),
      'gender': gender,
      'profileImageUrl': profileImageUrl,
    };
  }

  @override
  String toString() {
    return 'UserModel(email: $email, firstName: $firstName, lastName: $lastName, age: $age, gender: $gender, height: $height, weight: $weight, waist: $waist, neck: $neck, hip: $hip)';
  }
}
