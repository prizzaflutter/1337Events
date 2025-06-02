import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/logged_out_usecase.dart';
import 'package:the_elsewheres/ui/core/theme/theme_cubit/theme_cubit.dart';

class ProfilePage extends StatefulWidget {
  final UserProfile? userProfile;
  final LogOutUseCase logOutUseCase;
  const ProfilePage({super.key, required this.userProfile, required this.logOutUseCase});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with gradient
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Profile Image
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.onPrimary, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                                widget.userProfile?.image.versions.medium ??
                                    'https://via.placeholder.com/200'
                            ),
                            backgroundColor: colorScheme.surfaceContainer,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // User Name
                        Text(
                          widget.userProfile?.displayname ?? 'User Name',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@${widget.userProfile?.login ?? 'username'}',
                          style: TextStyle(
                            color: colorScheme.onPrimary.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Student Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colorScheme.onPrimary.withOpacity(0.3)),
                          ),
                          child: Text(
                            widget.userProfile?.kind?.toUpperCase() ?? 'STUDENT',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: colorScheme.onPrimary),
                onPressed: () {
                  // Edit profile functionality
                  _showEditProfileDialog();
                },
              ),
              IconButton(
                icon: Icon(Icons.settings, color: colorScheme.onPrimary),
                onPressed: () {
                  // Settings functionality
                },
              ),
            ],
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.stars,
                          title: 'Correction Points',
                          value: '${widget.userProfile?.correctionPoint ?? 0}',
                          color: colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.account_balance_wallet,
                          title: 'Wallet',
                          value: '${widget.userProfile?.wallet ?? 0}',
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Personal Information Card
                  _buildPersonalInfoCard(),

                  const SizedBox(height: 24),

                  // Account Details Card
                  _buildAccountDetailsCard(),

                  const SizedBox(height: 24),

                  // Profile Actions
                  Text(
                    'Profile Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildProfileActions(),

                  const SizedBox(height: 24),

                  // Preferences Card
                  _buildPreferencesCard(),

                  const SizedBox(height: 100), // Bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, 'Full Name', widget.userProfile?.usualFullName ?? widget.userProfile?.displayname ?? 'N/A'),
          _buildInfoRow(Icons.badge, 'First Name', widget.userProfile?.firstName ?? 'N/A'),
          _buildInfoRow(Icons.badge_outlined, 'Last Name', widget.userProfile?.lastName ?? 'N/A'),
          _buildInfoRow(Icons.phone, 'Phone', widget.userProfile?.phone == 'hidden' ? 'Private' : widget.userProfile?.phone ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.alternate_email, 'Login', widget.userProfile?.login ?? 'N/A'),
          _buildInfoRow(Icons.email, 'Email', widget.userProfile?.email ?? 'N/A'),
          _buildInfoRow(Icons.pool, 'Pool Period', '${widget.userProfile?.poolMonth ?? 'N/A'} ${widget.userProfile?.poolYear ?? ''}'),
          _buildInfoRow(Icons.location_on, 'Current Location', widget.userProfile?.location ?? 'Not available'),
          _buildInfoRow(Icons.calendar_today, 'Member Since', _formatDate(widget.userProfile?.createdAt.toIso8601String())),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions() {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.security,
            title: 'Privacy',
            color: colorScheme.primary,
            onTap: () {
              _showPrivacySettings();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.download,
            title: 'Export Data',
            color: colorScheme.secondary,
            onTap: () {
              _exportUserData();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.share,
            title: 'Share Profile',
            color: colorScheme.tertiary,
            onTap: () {
              _shareProfile();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildPreferenceItem(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Switch to dark theme',
            value: context.watch<ThemeCubit>().state == ThemeMode.dark,
            onChanged: (value) {
              final themeCubit = context.read<ThemeCubit>();
              themeCubit.toggleTheme();
              setState(() {
                // Force rebuild to apply theme changes
                value = context.watch<ThemeCubit>().state == ThemeMode.dark;
              });
            },
          ),
          _buildPreferenceItem(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            isSwitch: false,
            onTap: () {
              // Show language selection
            },
          ),
          _buildPreferenceItem(
            color: colorScheme.errorContainer,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            isSwitch: false,
            onTap: () async {
              // i want to show dialog to confirm logout
              final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async{
                          await widget.logOutUseCase.call();
                          context.go('/login');
                          Navigator.pop(context, true);
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    Color? color,
    required IconData icon,
    required String title,
    required String subtitle,
    bool value = false,
    bool isSwitch = true,
    ValueChanged<bool>? onChanged,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      tileColor: color ?? colorScheme.surface,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      trailing: isSwitch
          ? Switch(
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.primary,
      )
          : Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurfaceVariant),
      onTap: isSwitch ? null : onTap,
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings coming soon!')),
    );
  }

  void _exportUserData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export feature coming soon!')),
    );
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile sharing feature coming soon!')),
    );
  }
}