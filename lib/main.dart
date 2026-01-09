import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'services/firebase_messaging_service.dart';
import 'sesion/user_session.dart';
import 'vistas/auth/login_page.dart';
import 'vistas/supervisor/layout/supervisor_bottom_bar.dart';
import 'vistas/inspector/layout/inspector_bottom_bar.dart';
import 'vistas/trabajador/layout/trabajador_bottom_bar.dart';
import 'vistas/splash/welcome_splash_screen.dart';
import 'vistas/splash/terms_conditions_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('\n🌙 === MENSAJE RECIBIDO EN BACKGROUND === 🌙');
  print('Título: ${message.notification?.title}');
  print('Cuerpo: ${message.notification?.body}');
  print('Datos: ${message.data}');

  await Firebase.initializeApp();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  const AndroidNotificationDetails androidDetails =
  AndroidNotificationDetails(
    'notificaciones_inspector',
    'Notificaciones del Inspector',
    channelDescription: 'Notificaciones de faltas de equipo de seguridad',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    enableVibration: true,
    playSound: true,
  );

  const NotificationDetails notificationDetails =
  NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title ?? '⚠️ Notificación',
    message.notification?.body ?? '',
    notificationDetails,
    payload: message.data.toString(),
  );

  print('✅ Notificación mostrada desde BACKGROUND\n');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('\n🚀 === INICIANDO APLICACIÓN === 🚀\n');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ Firebase inicializado');

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  print('✅ Background message handler registrado');

  await FirebaseMessagingService.initializeFirebaseMessaging();
  print('✅ Firebase Messaging Service inicializado');

  print('\n🎉 Aplicación lista para recibir notificaciones\n');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WelcomeSplashScreen(),
      routes: {
        "/login": (_) => const LoginPage(),
        "/terms": (_) => const TermsConditionsScreen(),
        "/supervisor/menu": (_) => const SupervisorBottomBar(),
        "/inspector/menu": (_) => const InspectorBottomBar(),
        "/trabajador/menu": (_) => const TrabajadorBottomBar(),
      },
    );
  }
}