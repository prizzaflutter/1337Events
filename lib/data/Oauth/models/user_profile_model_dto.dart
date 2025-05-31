import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';

class UserProfileDto {
  final int id;
  final String email;
  final String login;
  final String firstName;
  final String lastName;
  final String usualFullName;
  final String? usualFirstName;
  final String url;
  final String phone;
  final String displayname;
  final String kind;
  final UserImageDto image;
  final bool isStaff;
  final int correctionPoint;
  final String poolMonth;
  final int poolYear;
  final String? location;
  final int wallet;
  final DateTime anonymizeDate;
  final DateTime dataErasureDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfileDto({
    required this.id,
    required this.email,
    required this.login,
    required this.firstName,
    required this.lastName,
    required this.usualFullName,
    this.usualFirstName,
    required this.url,
    required this.phone,
    required this.displayname,
    required this.kind,
    required this.image,
    required this.isStaff,
    required this.correctionPoint,
    required this.poolMonth,
    required this.poolYear,
    this.location,
    required this.wallet,
    required this.anonymizeDate,
    required this.dataErasureDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper method to safely parse integers
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    throw ArgumentError('Cannot parse $value to int');
  }

  // Helper method to safely parse booleans
  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    throw ArgumentError('Cannot parse $value to bool');
  }

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: _parseInt(json['id']),
      email: json['email'] as String,
      login: json['login'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      usualFullName: json['usual_full_name'] as String,
      usualFirstName: json['usual_first_name'] as String?,
      url: json['url'] as String,
      phone: json['phone'] as String,
      displayname: json['displayname'] as String,
      kind: json['kind'] as String,
      image: UserImageDto.fromJson(json['image'] as Map<String, dynamic>),
      isStaff: _parseBool(json['staff?']),
      correctionPoint: _parseInt(json['correction_point']),
      poolMonth: json['pool_month'] as String,
      poolYear: _parseInt(json['pool_year']),
      location: json['location'] as String?,
      wallet: _parseInt(json['wallet']),
      anonymizeDate: DateTime.parse(json['anonymize_date'] as String),
      dataErasureDate: DateTime.parse(json['data_erasure_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory UserProfileDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserProfileDto(
      id: data['id'] as int,
      email: data['email'] as String,
      login: data['login'] as String,
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      usualFullName: data['usual_full_name'] as String,
      usualFirstName: data['usual_first_name'] as String?,
      url: data['url'] as String,
      phone: data['phone'] as String,
      displayname: data['displayname'] as String,
      kind: data['kind'] as String,
      image: UserImageDto.fromFirestore(data['image'] as Map<String, dynamic>),
      isStaff: data['staff?'] as bool,
      correctionPoint: data['correction_point'] as int,
      poolMonth: data['pool_month'] as String,
      poolYear: data['pool_year'] as int,
      location: data['location'] as String?,
      wallet: data['wallet'] as int,
      anonymizeDate: (data['anonymize_date'] as Timestamp).toDate(),
      dataErasureDate: (data['data_erasure_date'] as Timestamp).toDate(),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'login': login,
      'first_name': firstName,
      'last_name': lastName,
      'usual_full_name': usualFullName,
      'usual_first_name': usualFirstName,
      'url': url,
      'phone': phone,
      'displayname': displayname,
      'kind': kind,
      'image': image.toJson(),
      'staff?': isStaff,
      'correction_point': correctionPoint,
      'pool_month': poolMonth,
      'pool_year': poolYear,
      'location': location,
      'wallet': wallet,
      'anonymize_date': anonymizeDate.toIso8601String(),
      'data_erasure_date': dataErasureDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'login': login,
      'first_name': firstName,
      'last_name': lastName,
      'usual_full_name': usualFullName,
      'usual_first_name': usualFirstName,
      'url': url,
      'phone': phone,
      'displayname': displayname,
      'kind': kind,
      'image': image.toFirestore(),
      'staff?': isStaff,
      'correction_point': correctionPoint,
      'pool_month': poolMonth,
      'pool_year': poolYear,
      'location': location,
      'wallet': wallet,
      'anonymize_date': Timestamp.fromDate(anonymizeDate),
      'data_erasure_date': Timestamp.fromDate(dataErasureDate),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  UserProfile toDomain() {
    return UserProfile(
      id: id,
      email: email,
      login: login,
      firstName: firstName,
      lastName: lastName,
      usualFullName: usualFullName,
      usualFirstName: usualFirstName,
      url: url,
      phone: phone,
      displayname: displayname,
      kind: kind,
      image: image.toDomain(),
      isStaff: isStaff,
      correctionPoint: correctionPoint,
      poolMonth: poolMonth,
      poolYear: poolYear,
      location: location,
      wallet: wallet,
      anonymizeDate: anonymizeDate,
      dataErasureDate: dataErasureDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class UserImageDto {
  final String link;
  final ImageVersionsDto versions;

  const UserImageDto({
    required this.link,
    required this.versions,
  });

  factory UserImageDto.fromJson(Map<String, dynamic> json) {
    return UserImageDto(
      link: json['link'] as String,
      versions: ImageVersionsDto.fromJson(json['versions'] as Map<String, dynamic>),
    );
  }

  factory UserImageDto.fromFirestore(Map<String, dynamic> data) {
    return UserImageDto(
      link: data['link'] as String,
      versions: ImageVersionsDto.fromFirestore(data['versions'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'link': link,
      'versions': versions.toJson(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'link': link,
      'versions': versions.toFirestore(),
    };
  }

  UserImage toDomain() {
    return UserImage(
      link: link,
      versions: versions.toDomain(),
    );
  }

  @override
  String toString() => 'UserImage(link: $link)';
}

class ImageVersionsDto {
  final String large;
  final String medium;
  final String small;
  final String micro;

  const ImageVersionsDto({
    required this.large,
    required this.medium,
    required this.small,
    required this.micro,
  });

  factory ImageVersionsDto.fromJson(Map<String, dynamic> json) {
    return ImageVersionsDto(
      large: json['large'] as String,
      medium: json['medium'] as String,
      small: json['small'] as String,
      micro: json['micro'] as String,
    );
  }

  factory ImageVersionsDto.fromFirestore(Map<String, dynamic> data) {
    return ImageVersionsDto(
      large: data['large'] as String,
      medium: data['medium'] as String,
      small: data['small'] as String,
      micro: data['micro'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'large': large,
      'medium': medium,
      'small': small,
      'micro': micro,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'large': large,
      'medium': medium,
      'small': small,
      'micro': micro,
    };
  }

  ImageVersions toDomain() {
    return ImageVersions(
      large: large,
      medium: medium,
      small: small,
      micro: micro,
    );
  }

  @override
  String toString() => 'ImageVersions(large: $large, medium: $medium, small: $small, micro: $micro)';
}