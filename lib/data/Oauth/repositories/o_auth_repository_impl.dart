import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as oauth2;
import 'package:the_elsewheres/data/Oauth/models/user_profile_model_dto.dart';
import 'package:the_elsewheres/data/Oauth/services/o_auth_service.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/Oauth/repositories/o_auth_repository.dart';

class OAuthRepositoryImpl implements OAuthRepository {
  final OAuthService dataSource;

  const OAuthRepositoryImpl(this.dataSource);

  @override
  Future<oauth2.Client?> authenticate(BuildContext context) async {
    return await dataSource.authenticate(context);
  }
  @override
  Future<bool> isLoggedIn() async {
    return await dataSource.isLoggedIn();
  }
  @override
  Future<void> logout() async {
    return await dataSource.logout();
  }
  @override
  Future<UserProfile?> getUserProfile() async {
    UserProfileDto? profile =  await dataSource.getUserProfile();
    return profile?.toDomain();
  }

}