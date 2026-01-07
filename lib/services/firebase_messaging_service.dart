import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static late FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin;

  static Future<void> initializeFirebaseMessaging() async {
    // Solicitar permisos de notificación
    NotificationSettings settings =
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Permiso de notificación: ${settings.authorizationStatus}');

    // Obtener el token de FCM
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Inicializar notificaciones locales
    _initializeLocalNotifications();

    // Manejar mensajes cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido en foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Manejar cuando el usuario toca una notificación (app en background o cerrada)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación tocada: ${message.notification?.title}');
      _handleNotificationTap(message);
    });

    // Manejar mensajes cuando la app está cerrada
    RemoteMessage? initialMessage =
    await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  static void _initializeLocalNotifications() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Notificación',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  static void _handleNotificationTap(RemoteMessage message) {
    print('Manejando notificación: ${message.data}');
    // Aquí puedes navegar a diferentes pantallas según el contenido
    // Ejemplo:
    // if (message.data['type'] == 'supervisor') {
    //   navigatorKey.currentState?.pushNamed('/supervisor/menu');
    // }
  }

  // Método para obtener el token de FCM
  static Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }
}