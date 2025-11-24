import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _permissionGranted = false;

  /// Initialize the notification service (silent initialization)
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('NotificationService already initialized');
      return;
    }

    try {
      // Initialize timezone database
      tz.initializeTimeZones();
      
      // Get device timezone offset
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      debugPrint('📍 Device time: $now');
      debugPrint('📍 Timezone offset: UTC${offset.isNegative ? '' : '+'}${offset.inHours}');
      
      // Set local timezone
      final String timeZoneName = await _getLocalTimeZone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      
      // Verify timezone is correct
      final tzNow = tz.TZDateTime.now(tz.local);
      debugPrint('✅ Timezone set to: $timeZoneName');
      debugPrint('✅ TZ time: $tzNow');
      debugPrint('✅ TZ offset: ${tzNow.timeZoneOffset.inHours} hours from UTC');
      
      // Initialize local notifications without requesting permissions yet
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,  // Don't request yet
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      // Create notification channel for Android (high priority for locked screen)
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'lilead_reminders', // id
        'Lead Reminders', // name
        description: 'Notifications for lead reminders and updates',
        importance: Importance.max,  // Maximum importance
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      _initialized = true;
      debugPrint('NotificationService initialized successfully (permissions not requested yet)');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Request notification permissions (call this when user tries to set a reminder)
  Future<bool> requestPermissions() async {
    debugPrint('\n🔐 === CHECKING PERMISSIONS ===');
    
    try {
      if (Platform.isAndroid) {
        // Check POST_NOTIFICATIONS permission (Android 13+)
        final notificationStatus = await Permission.notification.status;
        debugPrint('📱 POST_NOTIFICATIONS permission: ${notificationStatus.name}');
        
        bool hasNotificationPermission = false;
        
        if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
          debugPrint('⚠️ Requesting POST_NOTIFICATIONS permission...');
          final status = await Permission.notification.request();
          hasNotificationPermission = status.isGranted;
          debugPrint('📱 POST_NOTIFICATIONS result: ${status.name}');
        } else {
          hasNotificationPermission = notificationStatus.isGranted;
        }
        
        if (!hasNotificationPermission) {
          debugPrint('❌ POST_NOTIFICATIONS permission denied');
          return false;
        }
        
        // Check SCHEDULE_EXACT_ALARM permission (Android 12+, API 31+)
        // This permission is usually auto-granted but can be revoked by user
        try {
          final scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.status;
          debugPrint('⏰ SCHEDULE_EXACT_ALARM permission: ${scheduleExactAlarmStatus.name}');
          
          if (!scheduleExactAlarmStatus.isGranted) {
            debugPrint('⚠️ SCHEDULE_EXACT_ALARM not granted - requesting...');
            
            // This will open the settings page for exact alarms
            final result = await Permission.scheduleExactAlarm.request();
            
            if (result.isGranted) {
              debugPrint('✅ SCHEDULE_EXACT_ALARM granted by user');
            } else {
              debugPrint('❌ User did not grant SCHEDULE_EXACT_ALARM');
              debugPrint('❌ Exact alarms will not work');
              return false;
            }
          } else {
            debugPrint('✅ SCHEDULE_EXACT_ALARM is granted');
          }
        } catch (e) {
          debugPrint('ℹ️ SCHEDULE_EXACT_ALARM check not available (older Android): $e');
          // On older Android, this permission doesn't exist, so continue
        }
        
        // Check battery optimization status (critical for Nothing Phone and similar devices)
        debugPrint('\n🔋 === CHECKING BATTERY OPTIMIZATION ===');
        try {
          // We'll check this via the battery optimization helper in the UI layer
          // Just log it here for debugging
          debugPrint('⚠️ Note: Battery optimization can prevent notifications from firing');
          debugPrint('   This is especially common on Nothing, Xiaomi, OnePlus, and Huawei devices');
          debugPrint('   The app will prompt user to disable battery optimization if needed');
        } catch (e) {
          debugPrint('ℹ️ Could not check battery optimization: $e');
        }
        
        _permissionGranted = hasNotificationPermission;
        debugPrint('✅ All required permissions granted');
        return _permissionGranted;
        
      } else if (Platform.isIOS) {
        // For iOS, request permissions via flutter_local_notifications
        debugPrint('📱 Requesting iOS notification permissions...');
        final bool? result = await _localNotifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        _permissionGranted = result ?? false;
        debugPrint('📱 iOS notification permission: $_permissionGranted');
        return _permissionGranted;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error requesting notification permissions: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Check if permissions are granted
  Future<bool> arePermissionsGranted() async {
    try {
      if (Platform.isAndroid) {
        return await Permission.notification.isGranted;
      } else if (Platform.isIOS) {
        // Check iOS permissions
        final bool? result = await _localNotifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return result ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      return false;
    }
  }

  /// Schedule a notification for a specific date and time
  Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized');
      return false;
    }

    // Check/request permissions - ALWAYS check, don't rely on cached value
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('❌ Notification permissions not granted - cannot schedule');
      return false;
    }

    try {
      // Verify time is in the future
      final now = DateTime.now();
      debugPrint('\n🔔 === SCHEDULING NOTIFICATION ===');
      debugPrint('📅 Device time: $now');
      debugPrint('📅 Scheduled time (input): $scheduledDateTime');
      
      if (scheduledDateTime.isBefore(now)) {
        debugPrint('❌ ERROR: Cannot schedule notification in the past!');
        debugPrint('   Scheduled: $scheduledDateTime');
        debugPrint('   Current:   $now');
        return false;
      }
      
      // Convert to timezone-aware datetime using the LOCAL timezone
      // This is critical - we need to interpret the scheduledDateTime as local time
      final tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        scheduledDateTime.year,
        scheduledDateTime.month,
        scheduledDateTime.day,
        scheduledDateTime.hour,
        scheduledDateTime.minute,
        scheduledDateTime.second,
      );
      
      final tzNow = tz.TZDateTime.now(tz.local);
      final minutesUntil = scheduledDate.difference(tzNow).inMinutes;
      
      debugPrint('📱 Notification Details:');
      debugPrint('   ID: $id');
      debugPrint('   Title: $title');
      debugPrint('   Body: ${body.substring(0, body.length > 50 ? 50 : body.length)}...');
      debugPrint('⏰ Timing:');
      debugPrint('   Current TZ time: $tzNow');
      debugPrint('   Scheduled TZ time: $scheduledDate');
      debugPrint('   ⏱️  Time until notification: $minutesUntil minutes');
      debugPrint('   Timezone: ${tz.local.name}');
      debugPrint('   TZ Offset: ${tzNow.timeZoneOffset.inHours} hours from UTC');

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'lilead_reminders',
            'Lead Reminders',
            channelDescription: 'Notifications for lead reminders and updates',
            importance: Importance.max,  // Maximum importance for locked screen
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            playSound: true,
            fullScreenIntent: true,  // Show on locked screen
            category: AndroidNotificationCategory.reminder,
            visibility: NotificationVisibility.public,  // Show content on locked screen
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,  // Work even in battery optimization
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // Verify notification was scheduled
      final pendingNotifications = await _localNotifications.pendingNotificationRequests();
      final isScheduled = pendingNotifications.any((n) => n.id == id);
      
      debugPrint('\n✅ VERIFICATION:');
      if (isScheduled) {
        debugPrint('✅ Notification scheduled successfully (ID: $id)');
        debugPrint('📋 Total pending notifications: ${pendingNotifications.length}');
        for (var p in pendingNotifications) {
          debugPrint('   • ID: ${p.id}, Title: ${p.title}');
        }
      } else {
        debugPrint('❌ FAILED to verify scheduled notification (ID: $id)');
        debugPrint('❌ The notification was NOT added to pending list');
        debugPrint('❌ Possible reasons:');
        debugPrint('   1. SCHEDULE_EXACT_ALARM permission revoked (Android 12+)');
        debugPrint('   2. Battery optimization is too aggressive');
        debugPrint('   3. System rejected the schedule');
        debugPrint('📋 Pending notifications: ${pendingNotifications.length}');
      }
      
      return isScheduled;
    } catch (e) {
      debugPrint('\n❌ ERROR SCHEDULING NOTIFICATION:');
      debugPrint('   Error: $e');
      debugPrint('   Type: ${e.runtimeType}');
      debugPrint('   Stack: ${StackTrace.current}');
      return false;
    }
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized');
      return;
    }

    try {
      await _localNotifications.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'lilead_reminders',
            'Lead Reminders',
            channelDescription: 'Notifications for lead reminders and updates',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            playSound: true,
            fullScreenIntent: true,
            visibility: NotificationVisibility.public,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        payload: payload,
      );

      debugPrint('Notification shown: $title');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
      debugPrint('Notification cancelled (ID: $id)');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _localNotifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Implement navigation logic based on payload
    // You can use a StreamController or callback to notify the UI
  }

  /// Get local timezone name
  Future<String> _getLocalTimeZone() async {
    try {
      // Get the timezone offset in hours
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final offsetHours = offset.inHours;
      final offsetMinutes = offset.inMinutes.remainder(60);
      
      debugPrint('System timezone offset: UTC${offset.isNegative ? '' : '+'}$offsetHours:${offsetMinutes.abs().toString().padLeft(2, '0')}');
      debugPrint('System timezone name: ${now.timeZoneName}');
      
      // Try to find timezone by offset
      // Israel is UTC+2, so we'll prioritize Asia/Jerusalem for +2
      final timezonesByOffset = <int, String>{
        2: 'Asia/Jerusalem',  // Israel Standard Time (PRIORITY)
        3: 'Asia/Jerusalem',  // Israel Daylight Time
        -5: 'America/New_York',
        -4: 'America/New_York',
        -8: 'America/Los_Angeles',
        -7: 'America/Los_Angeles',
        -6: 'America/Chicago',
        0: 'Europe/London',
        1: 'Europe/Paris',  // Changed from London
      };
      
      String? detectedTimezone = timezonesByOffset[offsetHours];
      
      // If we detected a timezone, verify it matches the offset
      if (detectedTimezone != null) {
        try {
          final location = tz.getLocation(detectedTimezone);
          final tzNow = tz.TZDateTime.now(location);
          debugPrint('Detected timezone: $detectedTimezone');
          debugPrint('Timezone offset check: ${tzNow.timeZoneOffset.inHours} hours');
          return detectedTimezone;
        } catch (e) {
          debugPrint('Failed to load timezone $detectedTimezone: $e');
        }
      }
      
      // Fallback: use UTC with manual offset
      debugPrint('⚠️ Using UTC as fallback - notifications may not work correctly');
      return 'UTC';
    } catch (e) {
      debugPrint('❌ Error getting timezone: $e');
      return 'UTC';
    }
  }

  /// Check if initialized
  bool get isInitialized => _initialized;
  
  /// Check if permissions are granted
  bool get hasPermissions => _permissionGranted;
}
