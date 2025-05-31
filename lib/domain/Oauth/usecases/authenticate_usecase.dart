import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as oauth2;
import 'package:the_elsewheres/domain/Oauth/repositories/o_auth_repository.dart';

class AuthenticateUseCase {
  final OAuthRepository _oAuthRepository;
  const AuthenticateUseCase(this._oAuthRepository);
  Future<oauth2.Client?> call(BuildContext context) async {
    return await _oAuthRepository.authenticate(context);
  }
}