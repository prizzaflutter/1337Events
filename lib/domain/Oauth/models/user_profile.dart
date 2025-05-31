import 'package:the_elsewheres/data/Oauth/models/user_profile_model_dto.dart';

class UserProfile{
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
  final UserImage image;
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

  const UserProfile({
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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
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
      image: UserImage.fromJson(json['image'] as Map<String, dynamic>),
      isStaff: json['staff?'] as bool,
      correctionPoint: json['correction_point'] as int,
      poolMonth: json['pool_month'] as String,
      poolYear: json['pool_year'] as int,
      location: json['location'] as String?,
      wallet: json['wallet'] as int,
      anonymizeDate: DateTime.parse(json['anonymize_date'] as String),
      dataErasureDate: DateTime.parse(json['data_erasure_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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

  UserProfileDto toDto(){
  return  UserProfileDto(
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
      image: image.toDto(),
      isStaff: isStaff,
      correctionPoint: correctionPoint,
      poolMonth: poolMonth,
      poolYear: poolYear,
      location: location,
      wallet: wallet,
      anonymizeDate: anonymizeDate,
      dataErasureDate: dataErasureDate,
      createdAt: createdAt,
      updatedAt: updatedAt
    );
  }

}

class UserImage {
  final String link;
  final ImageVersions versions;

  const UserImage({
    required this.link,
    required this.versions,
  });

  factory UserImage.fromJson(Map<String, dynamic> json) {
    return UserImage(
      link: json['link'] as String,
      versions: ImageVersions.fromJson(json['versions'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'link': link,
      'versions': versions.toJson(),
    };
  }

  UserImageDto toDto() {
    return UserImageDto(
      link: link,
      versions: versions.toDto(),
    );
  }

  @override
  String toString() => 'UserImage(link: $link)';
}

class ImageVersions {
  final String large;
  final String medium;
  final String small;
  final String micro;

  const ImageVersions({
    required this.large,
    required this.medium,
    required this.small,
    required this.micro,
  });

  factory ImageVersions.fromJson(Map<String, dynamic> json) {
    return ImageVersions(
      large: json['large'] as String,
      medium: json['medium'] as String,
      small: json['small'] as String,
      micro: json['micro'] as String,
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

  ImageVersionsDto toDto (){
     return ImageVersionsDto(
        large: large,
        medium: medium,
        small: small,
        micro: micro,
      );
  }
  @override
  String toString() => 'ImageVersions(large: $large, medium: $medium, small: $small, micro: $micro)';
}
