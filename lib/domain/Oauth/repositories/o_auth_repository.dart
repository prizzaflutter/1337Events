import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as oauth2;
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';

abstract class OAuthRepository {
  // final OAuthDataSource dataSource;
  //
  // OAuthRepository(this.dataSource);
  //
  // Future<OAuthModel> getOAuthToken(String code) async {
  //   return await dataSource.getOAuthToken(code);
  // }
  Future<oauth2.Client?> authenticate(BuildContext context);
  Future<bool> isLoggedIn();
  Future<void> logout();
  Future<UserProfile> getUserProfile();
}