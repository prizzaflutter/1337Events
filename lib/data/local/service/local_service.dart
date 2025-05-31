import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_elsewheres/data/Oauth/models/user_profile_model_dto.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';

class LocalStorageService {
  final SharedPreferences sharedPreferences;

  const LocalStorageService(this.sharedPreferences);

  // Keys for different data types
  static const String _userProfileKey = 'user_profile';
  static const String _userProfileExpiryKey = 'user_profile_expiry';
  static const String _userTokenKey = 'user_token';
  static const String _userTokenExpiredKey = 'user_token_expired';
  static const Duration  _expiredTime = Duration(hours: 1); // 30 days

  Future<void> saveUserProfileToLocalStorage(UserProfile userProfile, {Duration? expiry}) async {
    try {
      final jsonString = jsonEncode(userProfile.toJson());
      final expirationDate = DateTime.now().add(expiry ?? _expiredTime).millisecondsSinceEpoch;
      await sharedPreferences.setString(_userProfileKey, jsonString);
      await sharedPreferences.setInt(_userProfileExpiryKey, expirationDate);
      debugPrint("User profile saved to local storage: ${userProfile.login}");
    } catch (e) {
      throw Exception("Failed to save user profile to local storage: $e");
    }
  }

  Future<UserProfileDto?> getUserProfileFromLocalStorage() async {
    try {
      final expiredTime = sharedPreferences.getInt(_userProfileExpiryKey);
      if (expiredTime != null && DateTime.now().millisecondsSinceEpoch > expiredTime) {
        debugPrint("User profile has expired, removing from local storage");
        await removeUserProfileFromLocalStorage();
        return null;
      }
      final jsonString = sharedPreferences.getString(_userProfileKey);
      if (jsonString != null) {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return UserProfileDto.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw Exception("Failed to load user profile from local storage: $e");
    }
  }

  Future<void> removeUserProfileFromLocalStorage() async {
    try {

      await sharedPreferences.remove(_userProfileKey);
      await sharedPreferences.remove(_userProfileExpiryKey);
      debugPrint("User profile removed from local storage");
    } catch (e) {
      throw Exception("Failed to remove user profile from local storage: $e");
    }
  }

  bool hasUserProfileInLocalStorage() {
    final expiredTime = sharedPreferences.getInt(_userProfileExpiryKey);
    if (expiredTime != null && DateTime.now().millisecondsSinceEpoch > expiredTime) {
      debugPrint("User profile has expired");
      return false; // Profile has expired
    }
    return sharedPreferences.containsKey(_userProfileKey);
  }

  /// Save user token
  Future<void> saveUserToken(String token, {Duration? expiredTime}) async {
    try {
      final expirationDate = DateTime.now().add(expiredTime ?? _expiredTime).millisecondsSinceEpoch;
      await sharedPreferences.setInt(_userTokenExpiredKey, expirationDate);
      await sharedPreferences.setString(_userTokenKey, token);
    } catch (e) {
      throw Exception("Failed to save user token: $e");
    }
  }

  /// Get user token
  String? getUserToken() {
    final expired = sharedPreferences.getInt(_userTokenExpiredKey);
    if (expired != null && DateTime.now().millisecondsSinceEpoch > expired) {
      removeUserToken(); // Remove expired token
      return null; // Token has expired
    }
    return sharedPreferences.getString(_userTokenKey);
  }

  Future<void> removeUserToken() async {
    try {
      await sharedPreferences.remove(_userTokenKey);
      await sharedPreferences.remove(_userTokenExpiredKey);
    } catch (e) {
      throw Exception("Failed to remove user token: $e");
    }
  }


  /// todo : this i will use when i logout the user
  Future<void> clearAllUserData() async {
    try {
      await Future.wait([
        sharedPreferences.remove(_userProfileKey),
        sharedPreferences.remove(_userProfileExpiryKey),
        sharedPreferences.remove(_userTokenKey),
        sharedPreferences.remove(_userTokenExpiredKey),
      ]);
      debugPrint("All user data cleared from local storage");
    } catch (e) {
      throw Exception("Failed to clear all user data: $e");
    }
  }

  /// Get all stored keys (for debugging)
  Set<String> getAllKeys() {
    return sharedPreferences.getKeys();
  }
}


/// todo : how i will use it :
/*
// Save user profile
await localStorageService.saveUserProfileToLocalStorage(userProfile);

// Load user profile
UserProfileDto? profile = await localStorageService.getUserProfileFromLocalStorage();

// Check if profile exists
bool hasProfile = localStorageService.hasUserProfileInLocalStorage();

// Remove profile
await localStorageService.removeUserProfileFromLocalStorage();
*////