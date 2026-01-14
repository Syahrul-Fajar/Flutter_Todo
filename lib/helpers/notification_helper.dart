import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Skip initialization on web platform
    if (kIsWeb) {
      print('Notifikasi tidak didukung di platform Web');
      return;
    }
    
    try {
      // Ensure timezone data is initialized
      tz_data.initializeTimeZones();
      
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          // Handle notification actions
          if (response.actionId == 'stop_alarm') {
            if (response.id != null) {
              await cancelNotification(response.id!);
              // Also stop the alarm manager service for this ID just in case
              if (Platform.isAndroid) {
                await AndroidAlarmManager.cancel(response.id!);
              }
            }
          }
        },
      );
      
      // Request permissions automatically on init
      await requestPermissions();
    } catch (e) {
      // Log error but don't crash the app
      print('Error initializing notifications: $e');
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return; // Skip on web
    
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
      
      // Request Exact Alarm permission for Android 12+
      if (await Permission.scheduleExactAlarm.status.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }

      // Request Storage/Audio permissions for custom sound
      if (Platform.isAndroid) {
         // Android 13+ (SDK 33) uses READ_MEDIA_AUDIO
         if (await Permission.audio.status.isDenied) {
           await Permission.audio.request();
         }
         // Older Android versions needing READ_EXTERNAL_STORAGE
         if (await Permission.storage.status.isDenied) {
           await Permission.storage.request();
         }
      }
    } else if (Platform.isIOS) {
       await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledTime, {String? soundPath}) async {
    if (kIsWeb) return; 
    
    // Ensure ID is within 32-bit integer range
    final int safeId = id > 2147483647 ? id % 2147483647 : id;

    try {
      if (scheduledTime.isBefore(DateTime.now())) {
        return;
      }

      // Use AndroidAlarmManager for robust background execution
      if (Platform.isAndroid) {
        await AndroidAlarmManager.oneShotAt(
          scheduledTime,
          safeId,
          NotificationHelper.alarmCallback,
          exact: true,
          wakeup: true,
          alarmClock: true,
          rescheduleOnReboot: true,
          params: {
            'title': title,
            'body': body,
            'soundPath': soundPath,
          },
        );
        print('Scheduled alarm with AndroidAlarmManager: ID $safeId at $scheduledTime');
      } else {
        // Fallback for iOS (Native Scheduling)
        // Determine sound configuration
        final hasCustomSound = soundPath != null && soundPath.isNotEmpty;
        
        await flutterLocalNotificationsPlugin.zonedSchedule(
          safeId,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              sound: hasCustomSound ? soundPath.split('/').last : null,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      
      print('Notification scheduled for ID: $safeId');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }


  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return; // Skip on web
    
    // Ensure ID is within 32-bit integer range
    final int safeId = id > 2147483647 ? id % 2147483647 : id;

    try {
      // Cancel system notification
      await flutterLocalNotificationsPlugin.cancel(safeId);
      
      // Cancel Android Alarm Manager entry
      if (Platform.isAndroid) {
         await AndroidAlarmManager.cancel(safeId);
      }
      
      print('Notification and Alarm cancelled for ID: $safeId');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  // ALARM MANAGER CALLBACK (Static, runs in background isolate)
  @pragma('vm:entry-point')
  static void alarmCallback(int id, Map<String, dynamic> params) async {
    print('AlarmCallback fired for ID: $id');
    final String title = params['title'] ?? 'Pengingat';
    final String body = params['body'] ?? 'Waktunya tugas Anda!';
    final String? soundPath = params['soundPath'];
    
    // Initialize notification helper in this background isolate
    final helper = NotificationHelper();
    // Re-init (safe to call multiple times)
    await helper.init();
    
    // Show notification immediately
    await helper.showNotificationNow(id, title, body, soundPath: soundPath);
  }

  Future<void> showNotificationNow(
      int id, String title, String body, {String? soundPath}) async {
      
      // Ensure ID is within 32-bit integer range
      final int safeId = id > 2147483647 ? id % 2147483647 : id;
      
      // Determine sound configuration
      final hasCustomSound = soundPath != null && soundPath.isNotEmpty;
      final channelId = hasCustomSound ? 'todo_channel_${soundPath.hashCode}' : 'todo_channel_id';
      final channelName = hasCustomSound ? 'Pengingat Custom' : 'Pengingat Tugas';
      
      UriAndroidNotificationSound? androidSound;
      if (hasCustomSound) {
        if (!soundPath.startsWith('file://') && !soundPath.startsWith('content://')) {
          androidSound = UriAndroidNotificationSound('file://$soundPath');
        } else {
          androidSound = UriAndroidNotificationSound(soundPath);
        }
      }

      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Channel untuk pengingat daftar tugas',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        playSound: true,
        sound: androidSound,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        category: AndroidNotificationCategory.alarm,
        ongoing: true,
        autoCancel: false,
        additionalFlags: Int32List.fromList(<int>[4]), // FLAG_INSISTENT
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'stop_alarm',
            'Matikan Alarm',
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      );

      await flutterLocalNotificationsPlugin.show(
        safeId,
        title,
        body,
        NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: DarwinNotificationDetails(
             presentAlert: true,
             presentBadge: true,
             presentSound: true,
             sound: hasCustomSound ? soundPath.split('/').last : null,
          ),
        ),
      );
  }
}
