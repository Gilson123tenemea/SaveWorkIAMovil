// ========================================
// PASO 1: ACTUALIZAR main.dart
// Archivo: lib/main.dart
// ========================================

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

// 🌙 PASO 1.1: AGREGAR MANEJADOR DE BACKGROUND
// Este código se ejecuta cuando la app ESTÁ CERRADA
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('\n🌙 === MENSAJE RECIBIDO EN BACKGROUND === 🌙');
  print('Título: ${message.notification?.title}');
  print('Cuerpo: ${message.notification?.body}');
  print('Datos: ${message.data}');

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Crear plugin de notificaciones
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Configurar Android
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Mostrar la notificación
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

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ Firebase inicializado');

  // 🌙 PASO 1.2: REGISTRAR EL MANEJADOR EN BACKGROUND
  // ⚠️ ESTO ES OBLIGATORIO - Sin esto no llegan notificaciones cuando app está cerrada
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  print('✅ Background message handler registrado');

  // Inicializar servicio de notificaciones
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
      home: const SplashScreen(),
      routes: {
        "/login": (_) => const LoginPage(),
        "/supervisor/menu": (_) => const SupervisorBottomBar(),
        "/inspector/menu": (_) => const InspectorBottomBar(),
        "/trabajador/menu": (_) => const TrabajadorBottomBar(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final session = UserSession();
    bool tieneSesion = await session.cargarSesion();

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    if (tieneSesion) {
      print('🔓 Sesión encontrada - Redirigiendo a: ${session.rol}');

      String ruta;

      if (session.rol == 'supervisor') {
        ruta = '/supervisor/menu';
      } else if (session.rol == 'inspector') {
        ruta = '/inspector/menu';
      } else if (session.rol == 'trabajador') {
        ruta = '/trabajador/menu';
      } else {
        ruta = '/login';
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, ruta);
      }
    } else {
      print('🔐 No hay sesión - Mostrando login');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}