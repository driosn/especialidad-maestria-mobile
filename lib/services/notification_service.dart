import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// ID del canal que debe coincidir con AndroidManifest y con el que creamos el canal.
const String _androidChannelId = 'high_importance_channel';

late FlutterLocalNotificationsPlugin _localNotifications;
late AndroidNotificationChannel _androidChannel;

/// Canal para usar en el isolate de background (mismo id que en el app).
const _backgroundChannel = AndroidNotificationChannel(
  _androidChannelId,
  'Notificaciones importantes',
  description: 'Canal para notificaciones push de Equilibra',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  showBadge: true,
);

/// Handler de mensajes en segundo plano (debe ser función top-level).
/// Corre en un isolate distinto: hay que inicializar el plugin y mostrar la notificación aquí.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[FCM Background] Notificación recibida: ${message.notification?.title} - ${message.notification?.body}');
  print('[FCM Background] Data: ${message.data}');

  // En background/terminated el plugin debe inicializarse en este isolate
  final plugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
  await plugin.initialize(
    const InitializationSettings(android: androidInit),
  );

  if (Platform.isAndroid) {
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_backgroundChannel);
  }

  final notification = message.notification;
  final title = notification?.title ?? message.data['title'] ?? '(Sin título)';
  final body = notification?.body ?? message.data['body'] ?? '';

  await plugin.show(
    message.hashCode,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        _backgroundChannel.name,
        channelDescription: _backgroundChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
        playSound: true,
        enableVibration: true,
      ),
    ),
  );
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    _localNotifications = FlutterLocalNotificationsPlugin();
    _androidChannel = const AndroidNotificationChannel(
      _androidChannelId,
      'Notificaciones importantes',
      description: 'Canal para notificaciones push de Equilibra',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear el canal en Android (importancia alta = se muestra en status bar)
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_androidChannel);
    }

    // Registrar handler para mensajes en segundo plano
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // iOS: mostrar notificación en primer plano (heads-up)
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Permisos (necesario en iOS)
    final settings = await _requestPermission();
    if (settings?.authorizationStatus == AuthorizationStatus.denied) {
      print('[FCM] Permisos de notificación denegados');
      return;
    }

    // Obtener e imprimir el FCM token al iniciar
    await _printFCMToken();

    // Listener: token refrescado
    _messaging.onTokenRefresh.listen((token) {
      print('[FCM] Token actualizado: $token');
    });

    // Listener: notificación con la app en primer plano (Android no la muestra; la mostramos nosotros)
    FirebaseMessaging.onMessage.listen(_onMessage);

    // Listener: usuario tocó la notificación (app en background)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Notificación que abrió la app desde estado terminado
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _printNotification('App abierta desde notificación (terminada)', initialMessage);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Opcional: navegar según response.payload
  }

  Future<NotificationSettings?> _requestPermission() async {
    if (Platform.isIOS) {
      return await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        print('[FCM] Permisos de notificación denegados (Android)');
      }
    }
    return null;
  }

  Future<void> _printFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        print('[FCM] Token: $token');
      } else {
        print('[FCM] No se pudo obtener el token (revisa configuración Firebase/Google)');
      }
    } catch (e, st) {
      print('[FCM] Error al obtener token: $e');
      print(st);
    }
  }

  void _onMessage(RemoteMessage message) {
    _printNotification('Notificación en primer plano', message);

    final notification = message.notification;
    final android = message.notification?.android;

    // En Android, FCM no muestra la notificación en primer plano; la mostramos nosotros en la barra de estado
    if (Platform.isAndroid && notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title ?? '(Sin título)',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannelId,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@drawable/ic_notification',
            playSound: true,
            enableVibration: true,
          ),
        ),
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    _printNotification('Usuario tocó notificación (app en background)', message);
  }

  void _printNotification(String context, RemoteMessage message) {
    print('[FCM] $context');
    print('[FCM]   title: ${message.notification?.title}');
    print('[FCM]   body: ${message.notification?.body}');
    print('[FCM]   data: ${message.data}');
  }
}
