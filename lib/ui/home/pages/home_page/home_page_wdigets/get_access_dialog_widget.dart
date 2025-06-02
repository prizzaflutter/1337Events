import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_elsewheres/domain/firebase/usercases/get_userId_from_login_usecase.dart';

enum AccessAction { grant, revoke }

class AccessManagementDialog extends StatefulWidget {
  final Function(String userId, bool giveAccess) onGrantAccess;
  final Function(String userId) onRevokeAccess;
  final Future<bool> Function(String username) checkUserExists;
  final Future<bool> Function(String username) checkUserHasAccess;
  final GetUserIdFromLoginUseCase getUserIdFromLoginUseCase;
  final AccessAction initialAction;

  const AccessManagementDialog({
    Key? key,
    required this.onGrantAccess,
    required this.onRevokeAccess,
    required this.checkUserExists,
    required this.checkUserHasAccess,
    required this.getUserIdFromLoginUseCase,
    this.initialAction = AccessAction.grant,
  }) : super(key: key);

  @override
  State<AccessManagementDialog> createState() => _AccessManagementDialogState();
}

class _AccessManagementDialogState extends State<AccessManagementDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isCheckingUser = false;
  String? _errorMessage;
  bool _userExists = false;
  bool _userHasAccess = false;
  String? _validatedUsername;
  String? _userId;
  AccessAction _currentAction = AccessAction.grant;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentAction = widget.initialAction;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkUsername(String username) async {
    if (username.trim().isEmpty) {
      setState(() {
        _errorMessage = null;
        _userExists = false;
        _userHasAccess = false;
        _validatedUsername = null;
        _userId = null;
      });
      return;
    }

    setState(() {
      _isCheckingUser = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Debounce

      // Check if user exists
      final exists = await widget.checkUserExists(username.trim());

      if (!exists) {
        if (mounted) {
          setState(() {
            _isCheckingUser = false;
            _userExists = false;
            _userHasAccess = false;
            _validatedUsername = username.trim();
            _userId = null;
            _errorMessage = 'User not found';
          });
        }
        return;
      }

      // Get user ID
      final userId = await widget.getUserIdFromLoginUseCase.call(username.trim());

      // Check if user has access
      final hasAccess = await widget.checkUserHasAccess(username.trim());

      if (mounted) {
        setState(() {
          _isCheckingUser = false;
          _userExists = exists;
          _userHasAccess = hasAccess;
          _validatedUsername = username.trim();
          _userId = userId;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingUser = false;
          _userExists = false;
          _userHasAccess = false;
          _userId = null;
          _errorMessage = 'Error checking user: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _performAction() async {
    if (!_formKey.currentState!.validate() || !_userExists || _userId == null) {
      return;
    }

    // Validate action based on current user status
    if (_currentAction == AccessAction.grant && _userHasAccess) {
      setState(() {
        _errorMessage = 'User already has admin access';
      });
      return;
    }

    if (_currentAction == AccessAction.revoke && !_userHasAccess) {
      setState(() {
        _errorMessage = 'User does not have admin access to revoke';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_currentAction == AccessAction.grant) {
        await widget.onGrantAccess(_userId!, true);
      } else {
        await widget.onRevokeAccess(_userId!);
      }

      if (mounted) {
        // Show success animation/feedback
        await _showSuccessAnimation();
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to ${_currentAction == AccessAction.grant ? 'grant' : 'revoke'} access: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _showSuccessAnimation() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessAnimationDialog(
        action: _currentAction,
        username: _validatedUsername!,
      ),
    );
  }

  String get _actionTitle {
    switch (_currentAction) {
      case AccessAction.grant:
        return 'Give Admin Access';
      case AccessAction.revoke:
        return 'Revoke Admin Access';
    }
  }

  String get _actionDescription {
    switch (_currentAction) {
      case AccessAction.grant:
        return 'Grant club admin privileges to a student';
      case AccessAction.revoke:
        return 'Remove club admin privileges from a student';
    }
  }

  IconData get _actionIcon {
    switch (_currentAction) {
      case AccessAction.grant:
        return Icons.admin_panel_settings;
      case AccessAction.revoke:
        return Icons.remove_moderator;
    }
  }

  String get _actionButtonText {
    switch (_currentAction) {
      case AccessAction.grant:
        return 'Grant Access';
      case AccessAction.revoke:
        return 'Revoke Access';
    }
  }

  bool get _canPerformAction {
    if (!_userExists || _userId == null) return false;

    switch (_currentAction) {
      case AccessAction.grant:
        return !_userHasAccess;
      case AccessAction.revoke:
        return _userHasAccess;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _currentAction == AccessAction.grant
                              ? colorScheme.primaryContainer
                              : colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _actionIcon,
                          color: _currentAction == AccessAction.grant
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onErrorContainer,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _actionTitle,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              _actionDescription,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
              
                  const SizedBox(height: 24),
              
                  // Action Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _isLoading ? null : () {
                              setState(() {
                                _currentAction = AccessAction.grant;
                                _errorMessage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: _currentAction == AccessAction.grant
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    size: 18,
                                    color: _currentAction == AccessAction.grant
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Grant',
                                    style: TextStyle(
                                      color: _currentAction == AccessAction.grant
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: _isLoading ? null : () {
                              setState(() {
                                _currentAction = AccessAction.revoke;
                                _errorMessage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: _currentAction == AccessAction.revoke
                                    ? colorScheme.error
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.remove_moderator,
                                    size: 18,
                                    color: _currentAction == AccessAction.revoke
                                        ? colorScheme.onError
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Revoke',
                                    style: TextStyle(
                                      color: _currentAction == AccessAction.revoke
                                          ? colorScheme.onError
                                          : colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              
                  const SizedBox(height: 24),
              
                  // Username Input Field
                  Text(
                    'Student Username',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
              
                  TextFormField(
                    controller: _usernameController,
                    enabled: !_isLoading,
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      // Debounced username checking
                      Future.delayed(const Duration(milliseconds: 800), () {
                        if (_usernameController.text == value) {
                          _checkUsername(value);
                        }
                      });
                    },
                    onFieldSubmitted: (_) => _performAction(),
                    decoration: InputDecoration(
                      hintText: 'Enter student username',
                      prefixIcon: Icon(
                        Icons.person_search,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: _buildSuffixIcon(colorScheme),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorScheme.error, width: 2),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainer.withOpacity(0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a username';
                      }
                      if (value.trim().length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      if (!_userExists && _validatedUsername == value.trim()) {
                        return 'User not found';
                      }
                      return null;
                    },
                  ),
              
                  // User Status Indicator
                  if (_validatedUsername != null) ...[
                    const SizedBox(height: 12),
                    _buildUserStatusIndicator(colorScheme),
                  ],
              
                  // Error Message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: colorScheme.error,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
              
                  const SizedBox(height: 32),
              
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(color: colorScheme.outline),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: (_isLoading || !_canPerformAction) ? null : _performAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentAction == AccessAction.grant
                                ? colorScheme.primary
                                : colorScheme.error,
                            foregroundColor: _currentAction == AccessAction.grant
                                ? colorScheme.onPrimary
                                : colorScheme.onError,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _currentAction == AccessAction.grant
                                    ? colorScheme.onPrimary
                                    : colorScheme.onError,
                              ),
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_actionIcon, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _actionButtonText,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuffixIcon(ColorScheme colorScheme) {
    if (_isCheckingUser) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      );
    }

    if (_validatedUsername != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          _userExists ? Icons.check_circle : Icons.cancel,
          color: _userExists ? Colors.green : colorScheme.error,
          size: 24,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildUserStatusIndicator(ColorScheme colorScheme) {
    if (!_userExists) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.error.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_off,
              color: colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'User not found: $_validatedUsername',
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // User found indicator
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'User found: $_validatedUsername',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Access status indicator
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _userHasAccess
                ? Colors.blue.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _userHasAccess
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _userHasAccess ? Icons.admin_panel_settings : Icons.person,
                color: _userHasAccess ? Colors.blue : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _userHasAccess
                      ? 'User has admin access'
                      : 'User does not have admin access',
                  style: TextStyle(
                    color: _userHasAccess ? Colors.blue : Colors.orange,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SuccessAnimationDialog extends StatefulWidget {
  final AccessAction action;
  final String username;

  const SuccessAnimationDialog({
    Key? key,
    required this.action,
    required this.username,
  }) : super(key: key);

  @override
  State<SuccessAnimationDialog> createState() => _SuccessAnimationDialogState();
}

class _SuccessAnimationDialogState extends State<SuccessAnimationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // Auto close after animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.action) {
      case AccessAction.grant:
        return 'Access Granted!';
      case AccessAction.revoke:
        return 'Access Revoked!';
    }
  }

  String get _subtitle {
    switch (widget.action) {
      case AccessAction.grant:
        return 'Admin privileges have been successfully granted to ${widget.username}';
      case AccessAction.revoke:
        return 'Admin privileges have been successfully revoked from ${widget.username}';
    }
  }

  Color get _color {
    switch (widget.action) {
      case AccessAction.grant:
        return Colors.green;
      case AccessAction.revoke:
        return Colors.orange;
    }
  }

  IconData get _icon {
    switch (widget.action) {
      case AccessAction.grant:
        return Icons.check;
      case AccessAction.revoke:
        return Icons.remove_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _checkAnimation,
                builder: (context, child) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: _color, width: 3),
                    ),
                    child: Transform.scale(
                      scale: _checkAnimation.value,
                      child: Icon(
                        _icon,
                        color: _color,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                _title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: _color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Usage functions
void showGrantAccessDialog(
    BuildContext context, {
      required Function(String userId, bool giveAccess) onGrantAccess,
      required Function(String userId) onRevokeAccess,
      required Future<bool> Function(String username) checkUserExists,
      required Future<bool> Function(String username) checkUserHasAccess,
      required GetUserIdFromLoginUseCase getUserIdFromLoginUseCase,
    }) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AccessManagementDialog(
        onGrantAccess: onGrantAccess,
        onRevokeAccess: onRevokeAccess,
        checkUserExists: checkUserExists,
        checkUserHasAccess: checkUserHasAccess,
        getUserIdFromLoginUseCase: getUserIdFromLoginUseCase,
        initialAction: AccessAction.grant,
      );
    },
  );
}

void showRevokeAccessDialog(
    BuildContext context, {
      required Function(String userId, bool giveAccess) onGrantAccess,
      required Function(String userId) onRevokeAccess,
      required Future<bool> Function(String username) checkUserExists,
      required Future<bool> Function(String username) checkUserHasAccess,
      required GetUserIdFromLoginUseCase getUserIdFromLoginUseCase,
    }) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AccessManagementDialog(
        onGrantAccess: onGrantAccess,
        onRevokeAccess: onRevokeAccess,
        checkUserExists: checkUserExists,
        checkUserHasAccess: checkUserHasAccess,
        getUserIdFromLoginUseCase: getUserIdFromLoginUseCase,
        initialAction: AccessAction.revoke,
      );
    },
  );
}

void showAccessManagementDialog(
    BuildContext context, {
      required Function(String userId, bool giveAccess) onGrantAccess,
      required Function(String userId) onRevokeAccess,
      required Future<bool> Function(String username) checkUserExists,
      required Future<bool> Function(String username) checkUserHasAccess,
      required GetUserIdFromLoginUseCase getUserIdFromLoginUseCase,
      AccessAction initialAction = AccessAction.grant,
    }) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AccessManagementDialog(
        onGrantAccess: onGrantAccess,
        onRevokeAccess: onRevokeAccess,
        checkUserExists: checkUserExists,
        checkUserHasAccess: checkUserHasAccess,
        getUserIdFromLoginUseCase: getUserIdFromLoginUseCase,
        initialAction: initialAction,
      );
    },
  );
}