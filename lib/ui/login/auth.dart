import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

// Callback type for handling OAuth results
typedef OAuthCallback = void Function(String? code, String? error, String? errorDescription);

class OAuthRedirectHandler extends StatefulWidget {
  final OAuthCallback? onAuthResult;

  const OAuthRedirectHandler({
    super.key,
    this.onAuthResult,
  });

  @override
  State<OAuthRedirectHandler> createState() => _OAuthRedirectHandlerState();
}

class _OAuthRedirectHandlerState extends State<OAuthRedirectHandler> {
  String _link = 'Waiting for authentication...';
  String _status = 'Initializing...';
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initAppLinks();
  }

  Future<void> _initAppLinks() async {
    try {
      setState(() {
        _status = 'Setting up deep link handler...';
      });

      // Get the initial app link if the app was started via a deep link
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint("Initial deep link: $initialUri");
        _parseDeepLink(initialUri);
      }

      // Listen for incoming app links while the app is running
      _linkSubscription = _appLinks.uriLinkStream.listen(
            (Uri? uri) {
          if (uri != null && !_isProcessing) {
            debugPrint("Received deep link: $uri");
            _parseDeepLink(uri);
          }
        },
        onError: (Object err) {
          debugPrint("Deep link error: $err");
          setState(() {
            _status = 'Deep link error: $err';
          });

          // Notify parent about the error
          if (widget.onAuthResult != null) {
            widget.onAuthResult!(null, 'deep_link_error', err.toString());
          }
        },
      );

      setState(() {
        _status = 'Ready to receive authentication callback...';
      });

    } catch (e) {
      debugPrint("Failed to initialize app links: $e");
      setState(() {
        _status = 'Failed to initialize: $e';
      });

      // Notify parent about the error
      if (widget.onAuthResult != null) {
        widget.onAuthResult!(null, 'initialization_error', e.toString());
      }
    }
  }

  void _parseDeepLink(Uri uri) {
    if (_isProcessing) {
      debugPrint("Already processing a deep link, ignoring...");
      return;
    }

    _isProcessing = true;

    debugPrint("Parsing redirect URI: $uri");

    setState(() {
      _link = uri.toString();
      _status = 'Processing authentication result...';
    });

    try {
      // Check if this is the expected redirect URI
      if (!uri.toString().startsWith("intra13://callback")) {
        debugPrint("Unexpected redirect URI scheme: ${uri.toString()}");
        setState(() {
          _status = 'Unexpected redirect URI received';
        });
        return;
      }

      // Extract parameters from the URI
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];
      final errorDescription = uri.queryParameters['error_description'];
      final state = uri.queryParameters['state'];

      if (error != null) {
        // OAuth error occurred
        debugPrint("OAuth error: $error - $errorDescription");
        setState(() {
          _status = 'Authentication failed: $error';
          _link = 'Error: $error${errorDescription != null ? ' - $errorDescription' : ''}';
        });

        // Notify parent about the error
        if (widget.onAuthResult != null) {
          widget.onAuthResult!(null, error, errorDescription);
        }

      } else if (code != null) {
        // Success - authorization code received
        debugPrint("Authorization code received: $code");
        debugPrint("State parameter: $state");

        setState(() {
          _status = 'Authentication successful! Processing...';
          _link = 'Authorization code received';
        });

        // Notify parent about the success
        if (widget.onAuthResult != null) {
          widget.onAuthResult!(code, null, null);
        }

        // Navigate back or close this screen
        if (mounted) {
          Navigator.of(context).pop();
        }

      } else {
        // No code or error - unexpected response
        debugPrint("Unexpected response: no code or error parameter");
        setState(() {
          _status = 'Unexpected response received';
          _link = 'No authorization code or error received';
        });

        // Notify parent about the unexpected response
        if (widget.onAuthResult != null) {
          widget.onAuthResult!(null, 'unexpected_response', 'No authorization code received');
        }
      }

    } catch (e) {
      debugPrint("Error parsing deep link: $e");
      setState(() {
        _status = 'Error processing authentication: $e';
      });

      // Notify parent about the parsing error
      if (widget.onAuthResult != null) {
        widget.onAuthResult!(null, 'parsing_error', e.toString());
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('42 OAuth Handler'),
        backgroundColor: const Color(0xFF00BABC),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _status.contains('error') || _status.contains('failed')
                              ? Icons.error_outline
                              : _status.contains('successful')
                              ? Icons.check_circle_outline
                              : Icons.info_outline,
                          color: _status.contains('error') || _status.contains('failed')
                              ? Colors.red
                              : _status.contains('successful')
                              ? Colors.green
                              : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Link Details Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.link, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Redirect Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _link,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. This screen handles OAuth redirects from 42 API\n'
                          '2. Complete the authentication in your browser\n'
                          '3. You will be redirected back to this app\n'
                          '4. The authorization code will be processed automatically',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}