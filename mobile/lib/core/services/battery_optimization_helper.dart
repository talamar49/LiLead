import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class BatteryOptimizationHelper {
  static const platform = MethodChannel('com.lilead.lilead/battery');

  /// Check if battery optimization is disabled
  static Future<bool> isBatteryOptimizationDisabled() async {
    if (!Platform.isAndroid) return true;
    
    try {
      final bool result = await platform.invokeMethod('isBatteryOptimizationDisabled');
      return result;
    } catch (e) {
      debugPrint('Error checking battery optimization: $e');
      return false;
    }
  }

  /// Request to disable battery optimization
  static Future<bool> requestDisableBatteryOptimization() async {
    if (!Platform.isAndroid) return true;
    
    try {
      final bool result = await platform.invokeMethod('requestDisableBatteryOptimization');
      return result;
    } catch (e) {
      debugPrint('Error requesting battery optimization: $e');
      return false;
    }
  }

  /// Show dialog to guide user to disable battery optimization
  static Future<void> showBatteryOptimizationDialog(BuildContext context) async {
    final isDisabled = await isBatteryOptimizationDisabled();
    
    if (isDisabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Battery optimization is already disabled'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.battery_alert, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('Battery Optimization Detected')),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications may not work reliably because battery optimization is enabled.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('To ensure notifications work:'),
              SizedBox(height: 8),
              Text('1. Tap "Open Settings" below'),
              Text('2. Find "LiLead" in the list'),
              Text('3. Select "Don\'t optimize" or "Unrestricted"'),
              Text('4. Return to the app'),
              SizedBox(height: 16),
              Text(
                '⚠️ Without this, Android may kill the app and prevent notifications from firing.',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await requestDisableBatteryOptimization();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Check all notification-related settings
  static Future<Map<String, bool>> checkAllSettings() async {
    return {
      'notifications': await Permission.notification.isGranted,
      'exactAlarms': await Permission.scheduleExactAlarm.isGranted,
      'batteryOptimization': await isBatteryOptimizationDisabled(),
    };
  }

  /// Show comprehensive settings check dialog
  static Future<void> showSettingsCheckDialog(BuildContext context) async {
    final settings = await checkAllSettings();
    
    if (!context.mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings Check'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingRow(
                'Notifications Permission',
                settings['notifications'] ?? false,
              ),
              _buildSettingRow(
                'Exact Alarms Permission',
                settings['exactAlarms'] ?? false,
              ),
              _buildSettingRow(
                'Battery Optimization Disabled',
                settings['batteryOptimization'] ?? false,
              ),
              const SizedBox(height: 16),
              if (!settings['batteryOptimization']!)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ Battery Optimization Issue',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your device is optimizing battery for this app, which may prevent notifications from working.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!settings['batteryOptimization']!)
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await showBatteryOptimizationDialog(context);
              },
              child: const Text('Fix Battery Settings'),
            ),
        ],
      ),
    );
  }

  static Widget _buildSettingRow(String label, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.black87 : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

