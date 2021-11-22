import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    final InitializationSettings initializationSettings = InitializationSettings(
        android: const AndroidInitializationSettings("@mipmap/yosicon"));

    _notificationsPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime
          .now()
          .millisecondsSinceEpoch ~/ 1000;

      // ignore: prefer_const_constructors
      final NotificationDetails notificationDetails = NotificationDetails(
          // ignore: prefer_const_constructors
          android: AndroidNotificationDetails(
            "yos_channel_id",//id
            "yos_channelIds_name",//name NOT description
            importance: Importance.max,
            priority: Priority.high,
          )
      );

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        "changed changed....",//did this to see if this got called...if it did get called
        notificationDetails,              //the text would change from the text that i made in the firebase console while sending the notification
        payload: message.data["route"],
      );
    } on Exception catch (e) {
      print(e);
    }
  }


  static Future<bool> wasChannelMade() async {
    bool ans = false;
    try {
      final List<AndroidNotificationChannel>? channels =
      await _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
          .getNotificationChannels();

      for (AndroidNotificationChannel channel in channels!) {
        print("===========${channel.id}========");
        if (channel.id == "yos_channel_id") {
          ans = true;
          break;
        }
      }
    }
    catch (e) {
      print(e);
    }

    return ans;
  }

  static Future<void> createChannel()  async {
      const AndroidNotificationChannel androidNotificationChannel =
      AndroidNotificationChannel(
        'yos_channel_id','yos_channelIds_name',
        description: 'channel description: made dynamically',
        importance: Importance.max,
      );
      await _notificationsPlugin.resolvePlatformSpecificImplementation
              <AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidNotificationChannel);

  }

  static Future<void> getNotificationChannelsInfo() async {
    try {
      final List<AndroidNotificationChannel>? channels =
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
          .getNotificationChannels();

              for (AndroidNotificationChannel channel in channels!) {
                print('id: ${channel.id}\n'
                    'name: ${channel.name}\n'
                    'description: ${channel.description}\n'
                    'groupId: ${channel.groupId}\n'
                    'importance: ${channel.importance.value}\n'
                    'playSound: ${channel.playSound}\n'
                    'sound: ${channel.sound?.sound}\n'
                    'enableVibration: ${channel.enableVibration}\n'
                    'vibrationPattern: ${channel.vibrationPattern}\n'
                    'showBadge: ${channel.showBadge}\n'
                    'enableLights: ${channel.enableLights}\n'
                    'ledColor: ${channel.ledColor}\n'
                    '============================');
              }
    } catch (e) {
       print(e);
    }

}



}//end of class