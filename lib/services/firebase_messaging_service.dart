import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../sesion/user_session.dart';
import '../servicios/fcm_token_api.dart';

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

    print('✅ Permiso de notificación: ${settings.authorizationStatus}');

    // Obtener el token de FCM
    String? token = await _firebaseMessaging.getToken();
    print('📱 FCM Token obtenido: ${token?.substring(0, 20)}...');

    // Inicializar notificaciones locales
    _initializeLocalNotifications();

    // Manejar mensajes cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('💬 Mensaje recibido en foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Manejar cuando el usuario toca una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('👆 Notificación tocada: ${message.notification?.title}');
      _handleNotificationTap(message);
    });

    // Manejar mensajes cuando la app está cerrada
    RemoteMessage? initialMessage =
    await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Escuchar cambios en el token (renovación)
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('🔄 Token FCM renovado: ${newToken.substring(0, 20)}...');
      // Si el usuario es inspector, re-registrar el nuevo token
      _reRegistrarTokenSiEsInspector(newToken);
    });
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
    print('📨 Manejando notificación: ${message.data}');
    // Aquí navegar según el contenido si es necesario
  }

  /// 📱 Obtiene el token de FCM
  static Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// 🔐 Registra el token en el backend SOLO si el inspector está autenticado
  static Future<void> registrarTokenFCMEnBackend() async {
    final session = UserSession();

    print('\n🔐 === VALIDACIÓN PARA REGISTRO DE TOKEN === 🔐');

    // ❌ PASO 1: Validar que hay sesión activa
    if (session.rol == null) {
      print('⚠️ [1/3] NO HAY SESIÓN ACTIVA');
      print('❌ No se registrará token\n');
      return;
    }

    print('✅ [1/3] Hay sesión activa');

    // ❌ PASO 2: Validar que el rol es "inspector"
    print('🔍 [2/3] Verificando rol del usuario...');
    print('    Rol actual: ${session.rol}');

    if (session.rol != "inspector") {
      print('❌ El rol NO es inspector (es: ${session.rol})');
      print('❌ No se registrará token\n');
      return;
    }

    print('✅ [2/3] Usuario ES inspector');

    // ❌ PASO 3: Validar que tiene ID de inspector
    print('🔍 [3/3] Obteniendo ID del inspector...');

    if (session.idInspector == null) {
      print('❌ ID inspector no disponible');
      print('❌ No se registrará token\n');
      return;
    }

    print('✅ [3/3] ID inspector disponible: ${session.idInspector}');

    // ✅ TODOS LOS VALIDADORES PASARON
    print('\n✅ ✅ ✅ VALIDACIÓN COMPLETA - REGISTRANDO TOKEN ✅ ✅ ✅\n');

    try {
      String? token = await getFCMToken();

      if (token == null) {
        print('❌ No se pudo obtener token FCM');
        return;
      }

      // Registrar en backend
      final response = await FCMTokenApi.registrarTokenFCM(
        session.idInspector!,
        token,
      );

      print('✅ ÉXITO: Token registrado en el backend');
      print('   ID Token: ${response.idFcmToken}');
      print('   Inspector: ${response.idInspector}');
      print('   Token: ${response.tokenFcm.substring(0, 20)}...\n');
    } catch (e) {
      print('❌ ERROR al registrar token en backend: $e\n');
    }
  }

  /// 🔄 Re-registrar token si es inspector (cuando se renueva)
  static Future<void> _reRegistrarTokenSiEsInspector(String newToken) async {
    final session = UserSession();

    // Solo re-registrar si es inspector
    if (session.rol == "inspector" && session.idInspector != null) {
      try {
        print('🔄 Re-registrando token renovado en backend...');
        await FCMTokenApi.registrarTokenFCM(
          session.idInspector!,
          newToken,
        );
        print('✅ Token renovado registrado en backend');
      } catch (e) {
        print('⚠️ Error al re-registrar token: $e');
      }
    }
  }

  /// 🗑️ Eliminar token al hacer logout (SOLO si es inspector)
  static Future<void> eliminarTokenAlLogout() async {
    final session = UserSession();

    // Solo eliminar si es inspector
    if (session.rol != "inspector" || session.idInspector == null) {
      print('⚠️ No es inspector. No se elimina token.');
      return;
    }

    try {
      String? token = await getFCMToken();
      if (token != null) {
        await FCMTokenApi.eliminarToken(session.idInspector!, token);
        print('🗑️ Token eliminado del backend al hacer logout');
      }
    } catch (e) {
      print('⚠️ Error al eliminar token: $e');
      // No lanzar excepción, permitir logout aunque falle la eliminación
    }
  }
}