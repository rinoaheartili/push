import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';
import 'package:push/config/security/dio_client.dart';

import 'package:push/domain/entities/push_message.dart';
import 'package:push/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async 
{
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> 
{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(const NotificationsState()) 
  {
    on<NotificationStatusChanged>(_notificationStatusChanged);
    on<NotificationReceived>(_onPushMessageReceived);
    on<ClearNotifications>(_onClearNotifications);

    // Verificar estado de las notificaciones
    _initialStatusCheck();

    // Listener para notificaciones en Foreground
    _onForegroundMessage();

    // Carga los mensaje de la base de datos hive
    _loadStoredMessages();

    // Solicitar permisos al arrancar por primera vez la app
    requestPermission();

    // Borras un elemento al deslizar hacia un lado
    on<DeleteNotification>(_onDeleteNotification);
  }

  static Future<void> initializeFCM() async 
  {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _notificationStatusChanged(NotificationStatusChanged event, Emitter<NotificationsState> emit) 
  {
    emit(
      state.copyWith(
        status: event.status
      )
    );
    _getFCMToken();
  }

  void _loadStoredMessages() 
  {
    final box = Hive.box<PushMessage>('push_messages');
    final storedMessages = box.values.toList().reversed.toList();
    for (final msg in storedMessages) {
      add(NotificationReceived(msg));
    }
  }
  
  void _onPushMessageReceived(NotificationReceived event, Emitter<NotificationsState> emit) async
  {
    final box = Hive.box<PushMessage>('push_messages');
    if (!box.containsKey(event.pushMessage.messageId)) 
    {
      await box.put(event.pushMessage.messageId, event.pushMessage);
    }
    emit(
      state.copyWith(
        notifications: [event.pushMessage, ...state.notifications]
      )
    );
  }

  void _onDeleteNotification(DeleteNotification event, Emitter<NotificationsState> emit) async 
  {
    final box = Hive.box<PushMessage>('push_messages');

    // Remueve de Hive
    await box.delete(event.messageId);

    // Remueve del estado actual
    final updatedList = state.notifications.where((n) => n.messageId != event.messageId).toList();

    emit(state.copyWith(notifications: updatedList));
  }

  void _onClearNotifications(ClearNotifications event, Emitter<NotificationsState> emit) async 
  {
    final box = Hive.box<PushMessage>('push_messages');
    await box.clear();
    emit(state.copyWith(notifications: []));
  }

  void _initialStatusCheck() async 
  {
    final settings = await messaging.getNotificationSettings();
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  void _getFCMToken() async 
  {
    if(state.status != AuthorizationStatus.authorized) return;
  
    final token = await messaging.getToken();
    if (token != null) {
      await enviarTokenAlBackend(token);
    } else {
      print('Token FCM no disponible');
    }
    print(token);
  }

  void handleRemoteMessage(RemoteMessage message) 
  {
    if(message.notification == null) return;
    
    final notification = PushMessage(
      messageId: message.messageId
        ?.replaceAll(':', '').replaceAll('%', '')
        ?? '',
      title: message.notification!.title ?? '',
      body: message.notification!.body ?? '',
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isAndroid
        ? message.notification!.android?.imageUrl
        : message.notification!.apple?.imageUrl
    );

    add(NotificationReceived(notification));
  }

  void _onForegroundMessage()
  {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void requestPermission() async 
  {
    final settings = await messaging.getNotificationSettings();
    if(settings.authorizationStatus == AuthorizationStatus.notDetermined) 
    {
      NotificationSettings newSettings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );
      add(NotificationStatusChanged(newSettings.authorizationStatus));
    } else {
      add(NotificationStatusChanged(settings.authorizationStatus));
    }
  }

  PushMessage? getMessageById(String pushMessageId) 
  {
    final exist = state.notifications.any((element) => element.messageId == pushMessageId);
    if (!exist) return null;

    return state.notifications.firstWhere((element) => element.messageId == pushMessageId);
  }

}
