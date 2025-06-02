import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:the_elsewheres/networking/network_cubit.dart';

class NoInternetPage extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onRetry;

  const NoInternetPage({
    Key? key,
    this.child,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, state) {
        // If connected, show the child widget
        if (state is NetworkConnected && child != null) {
          return child!;
        }

        // If disconnected or initial, show no internet page
        return _buildNoInternetPage(context, state);
      },
    );
  }

  Widget _buildNoInternetPage(BuildContext context, NetworkState state) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Section
              _buildIconSection(context),

              SizedBox(height: 32.h),

              // Title and Description
              _buildTextSection(context),

              SizedBox(height: 24.h),

              // Connection Status
              _buildConnectionStatus(context, state),

              SizedBox(height: 32.h),

              // Action Buttons
              _buildActionButtons(context, state),

              SizedBox(height: 24.h),

              // Tips Section
              _buildTipsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconSection(BuildContext context) {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 2.w,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.wifi_off_rounded,
          size: 48.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTextSection(BuildContext context) {
    return Column(
      children: [
        Text(
          'No Internet Connection',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Text(
          'Check your internet connection and try again.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildConnectionStatus(BuildContext context, NetworkState state) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (state is NetworkConnected) {
      statusColor = Theme.of(context).colorScheme.primary;
      statusText = 'Connected';
      statusIcon = Icons.wifi;
    } else if (state is NetworkDisconnected) {
      statusColor = Theme.of(context).colorScheme.error;
      statusText = 'Disconnected';
      statusIcon = Icons.wifi_off;
    } else {
      statusColor = Theme.of(context).colorScheme.secondary;
      statusText = 'Checking...';
      statusIcon = Icons.wifi_find;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, NetworkState state) {
    final isChecking = state is NetworkInitial;

    return Column(
      children: [
        // Primary Retry Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isChecking ? null : () => _handleRetry(context),
            icon: isChecking
                ? SizedBox(
              width: 18.w,
              height: 18.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            )
                : Icon(Icons.refresh, size: 18.sp),
            label: Text(
              isChecking ? 'Checking...' : 'Try Again',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Secondary Settings Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openWifiSettings(context),
            icon: Icon(Icons.settings, size: 18.sp),
            label: Text(
              'Open Settings',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.w,
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    final tips = [
      'Check Wi-Fi connection',
      'Verify mobile data',
      'Move closer to router',
      'Restart your device',
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Troubleshooting Tips',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 12.h),
          ...tips.map((tip) => Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  void _handleRetry(BuildContext context) {
    // Call custom retry callback if provided
    if (onRetry != null) {
      onRetry!();
    }

    // Trigger network check
    context.read<NetworkCubit>().checkConnectivity();

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Checking connection...',
          style: TextStyle(fontSize: 14.sp),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openWifiSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          'Network Settings',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        content: Text(
          'Go to your device settings to configure Wi-Fi or mobile data connection.',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Wrapper widget to handle network state globally
class NetworkAwareWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRetry;

  const NetworkAwareWrapper({
    Key? key,
    required this.child,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, state) {
        if (state is NetworkDisconnected) {
          return NoInternetPage(
            child: child,
            onRetry: onRetry,
          );
        }
        return child;
      },
    );
  }
}