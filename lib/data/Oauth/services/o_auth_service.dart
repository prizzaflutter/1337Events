import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;
import 'package:the_elsewheres/data/Oauth/models/user_profile_model_dto.dart';

class OAuthService {
  final FlutterSecureStorage _flutterSecureStorage = const FlutterSecureStorage();
  static const String _accessToken = "access_token";
  static const String _refreshTokenKey = "refresh_token";
  static const String _expiryDateKey = "expiry_date";

  // IMPORTANT: Verify these credentials in your 42 app settings
  final String clientId = dotenv.env['CLIENT_ID'] ?? '';
  final String clientSecret = dotenv.env['SECRET_ID'] ?? '';
  final String redirectUri = "theelsewheres://callback";
  final String authorizationUrl = "https://api.intra.42.fr/oauth/authorize";
  final String tokenEndpoint = "https://api.intra.42.fr/oauth/token";
  final String scope = "public";
  final String baseUrl = "https://api.intra.42.fr";

  oauth2.Client? _client;

  // Improved WebView authentication with better error handling
  Future<Uri?> _getRedirectedUri(String authUrl, BuildContext context) async {
    Uri? redirectedUri;
    String? errorMessage;

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text("42 Authentication"),
              backgroundColor: const Color(0xFF00BABC),
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(authUrl)),
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                iframeAllow: "camera; microphone",
                iframeAllowFullscreen: true,
                javaScriptEnabled: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                clearCache: true,
                clearSessionCache: true,
                userAgent: "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36",
              ),
              onWebViewCreated: (controller) {
                debugPrint("WebView created successfully");
              },
              onLoadStart: (controller, url) {
                debugPrint("Loading started: ${url?.toString()}");

                if (url != null && url.toString().startsWith(redirectUri)) {
                  redirectedUri = Uri.parse(url.toString());
                  debugPrint("Redirect detected: $redirectedUri");
                  Navigator.pop(context);
                } else if (url != null && url.toString().contains('error')) {
                  // Handle OAuth errors in URL
                  final uri = Uri.parse(url.toString());
                  final error = uri.queryParameters['error'];
                  final errorDescription = uri.queryParameters['error_description'];
                  errorMessage = "OAuth Error: ${error ?? 'Unknown'} - ${errorDescription ?? 'No description'}";
                  Navigator.pop(context);
                }
              },
              onLoadStop: (controller, url) {
                debugPrint("Loading completed: ${url?.toString()}");
              },
              onReceivedError: (controller, request, error) {
                debugPrint("WebView error: ${error.description}");
                errorMessage = "WebView error: ${error.description}";
              },
              onReceivedHttpError: (controller, request, errorResponse) {
                debugPrint("HTTP error: ${errorResponse.statusCode}");
                errorMessage = "HTTP error: ${errorResponse.statusCode}";
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url;
                if (url != null && url.toString().startsWith(redirectUri)) {
                  redirectedUri = Uri.parse(url.toString());
                  Navigator.pop(context);
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint("WebView navigation error: $e");
      errorMessage = "Navigation error: $e";
    }

    if (errorMessage != null) {
      throw Exception(errorMessage);
    }

    return redirectedUri;
  }

  // Enhanced authentication with better error handling
  Future<oauth2.Client?> authenticate(BuildContext context) async {
    try {
      debugPrint("Starting authentication process...");

      // Verify client credentials first
      final isValidClient = await _verifyClientCredentials();
      if (!isValidClient) {
        throw Exception("Invalid client credentials. Please check your 42 app configuration.");
      }

      final authorizationURL = Uri.parse(authorizationUrl);
      final redirectURL = Uri.parse(redirectUri);
      debugPrint("the redict URL: $redirectURL");

      final grant = oauth2.AuthorizationCodeGrant(
        clientId,
        authorizationURL,
        Uri.parse(tokenEndpoint),
        secret: clientSecret,
      );

      final authUrl = grant.getAuthorizationUrl(
        redirectURL,
        scopes: [scope],
        state: _generateRandomState(), // Add state for security
      );

      debugPrint("Authorization URL: $authUrl");

      final redirectedUri = await _getRedirectedUri(authUrl.toString(), context);

      if (redirectedUri != null) {
        debugPrint("Processing redirect URI: $redirectedUri");

        // Check for errors in the redirect
        final error = redirectedUri.queryParameters['error'];
        if (error != null) {
          final errorDescription = redirectedUri.queryParameters['error_description'];
          throw Exception("OAuth Error: $error - ${errorDescription ?? 'No description'}");
        }

        _client = await grant.handleAuthorizationResponse(redirectedUri.queryParameters);

        if (_client != null) {
          await _saveCredentials(_client!.credentials);
          debugPrint("Authentication successful!");
          return _client;
        } else {
          throw Exception("Failed to create OAuth client");
        }
      } else {
        throw Exception("No redirect URI received - authentication was cancelled or failed");
      }
    } on oauth2.AuthorizationException catch (e) {
      debugPrint("OAuth Authorization Exception: ${e.error} - ${e.description}");
      throw Exception("OAuth Error: ${e.error} - ${e.description ?? 'Authentication failed'}");
    } on oauth2.ExpirationException catch (e) {
      debugPrint("OAuth Expiration Exception: $e");
      throw Exception("Authentication expired. Please try again.");
    } catch (e) {
      debugPrint("Authentication error: $e");
      rethrow;
    }
  }

  // Verify client credentials before attempting OAuth
  Future<bool> _verifyClientCredentials() async {
    try {
      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        debugPrint("Client credentials are valid");
        return true;
      } else {
        debugPrint("Client credentials verification failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error verifying client credentials: $e");
      return false;
    }
  }

  // Generate random state for OAuth security
  String _generateRandomState() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return random;
  }

  Future<void> _saveCredentials(oauth2.Credentials credentials) async {
    await _flutterSecureStorage.write(key: _accessToken, value: credentials.accessToken);
    await _flutterSecureStorage.write(key: _refreshTokenKey, value: credentials.refreshToken);
    await _flutterSecureStorage.write(key: _expiryDateKey, value: credentials.expiration?.toIso8601String());
    debugPrint("Credentials saved successfully");
  }

  Future<oauth2.Credentials?> _getStoredCredentials() async {
    final accessToken = await _flutterSecureStorage.read(key: _accessToken);
    final refreshToken = await _flutterSecureStorage.read(key: _refreshTokenKey);
    final expiryDate = await _flutterSecureStorage.read(key: _expiryDateKey);

    if (accessToken != null && expiryDate != null) {
      return oauth2.Credentials(
          accessToken,
          refreshToken: refreshToken,
          expiration: DateTime.parse(expiryDate)
      );
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    try {
      final credentials = await _getStoredCredentials();
      debugPrint("credentials: $credentials");
      if (credentials != null) {
        if (credentials.isExpired) {
          debugPrint("Token is expired, attempting refresh...");
          if (credentials.canRefresh) {
            final refreshedCredentials = await credentials.refresh(
              identifier: clientId,
              secret: clientSecret,
            );
            await _saveCredentials(refreshedCredentials);
            _client = oauth2.Client(refreshedCredentials);
            debugPrint("Token refreshed successfully");
            return true;
          } else {
            debugPrint("Cannot refresh token, user needs to re-authenticate");
            await logout(); // Clear invalid credentials
            return false;
          }
          // printing credentials for debugging
        } else {
          _client = oauth2.Client(credentials);
          debugPrint("Valid credentials found");
          return true;
        }
      }
    } catch (e) {
      debugPrint("Error checking login status: $e");
      await logout(); // Clear potentially corrupted credentials
    }
    return false;
  }

  Future<void> logout() async {
    try {
      await _flutterSecureStorage.deleteAll();
      _client = null;
      debugPrint("Logout successful");
    } catch (e) {
      debugPrint("Error during logout: $e");
    }
  }

  // Improved user profile method with better error handling
  Future<UserProfileDto> getUserProfile() async {
    if (_client == null) {
      final isLoggedIn = await this.isLoggedIn();
      if (!isLoggedIn) {
        // todo : instead of throw exceptio : navigate to login page or ask user for it
        throw Exception("User is not authenticated");
      }
    }

    try {
      final response = await _client!.get(Uri.parse("$baseUrl/v2/me"));

      if (response.statusCode == 200) {
        final profileData = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint("User profile fetched successfully - $profileData");
        debugPrint("User Profile: ${profileData['login']} - ${profileData['email']}");
        return UserProfileDto.fromJson(profileData);
      } else if (response.statusCode == 401) {
        // Token might be invalid, try to refresh
        final isLoggedIn = await this.isLoggedIn();
        if (isLoggedIn) {
          // Retry with refreshed token
          return await getUserProfile();
        } else {
          throw Exception("Authentication expired. Please log in again.");
        }
      } else {
        throw Exception("Failed to get user profile: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error getting user profile: $e");
      rethrow;
    }
  }

}