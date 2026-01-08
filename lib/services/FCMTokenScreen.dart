import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FCMTokenScreen extends StatefulWidget {
  @override
  State<FCMTokenScreen> createState() => _FCMTokenScreenState();
}

class _FCMTokenScreenState extends State<FCMTokenScreen> {
  String? fcmToken;
  late FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    _firebaseMessaging = FirebaseMessaging.instance;

    // Solicitar permisos de notificación
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permisos de notificación concedidos');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('Permisos provisionales concedidos');
    } else {
      print('Permisos de notificación denegados');
    }

    // Obtener el token FCM
    String? token = await _firebaseMessaging.getToken();
    setState(() {
      fcmToken = token;
    });

    print('Token FCM: $token');

    // Escuchar cambios en el token
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      setState(() {
        fcmToken = newToken;
      });
      print('Nuevo Token FCM: $newToken');
    });

    // Manejar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido en primer plano:');
      print('Título: ${message.notification?.title}');
      print('Cuerpo: ${message.notification?.body}');

      // Mostrar notificación local
      _showNotification(message);
    });

    // Manejar cuando el usuario toca una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación abierta: ${message.notification?.title}');
      // Aquí puedes navegar a una pantalla específica
    });
  }

  void _showNotification(RemoteMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message.notification?.title ?? 'Notificación'),
        content: Text(message.notification?.body ?? 'Sin contenido'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard() {
    if (fcmToken != null) {
      // Aquí copias el token al portapapeles
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token copiado al portapapeles')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token FCM'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu Token FCM:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (fcmToken == null)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue.withOpacity(0.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      fcmToken!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar Token'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            const Text(
              'Próximos pasos:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Copia el token de arriba\n'
                  '2. Ve a Firebase Console → Cloud Messaging\n'
                  '3. Click en "Enviar tu primer mensaje"\n'
                  '4. Rellena título y texto\n'
                  '5. En "Dispositivos de prueba" pega tu token\n'
                  '6. Click en "Enviar mensaje de prueba"',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}