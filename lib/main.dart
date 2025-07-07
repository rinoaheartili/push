import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push/config/router/app_router.dart';
import 'package:push/config/theme/app_theme.dart';
import 'package:push/domain/entities/push_message.dart';
import 'package:push/presentation/blocs/notifications/notifications_bloc.dart';

void main() async 
{
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationsBloc.initializeFCM();

  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  Hive.registerAdapter(PushMessageAdapter());

  await Hive.openBox<PushMessage>('push_messages');
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NotificationsBloc())
      ], 
      child: const MainApp())
  );

}

class MainApp extends StatelessWidget 
{
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      builder: (context, child) => HandleNotificationInteractions(child: child!),
    );
  }
}


class HandleNotificationInteractions extends StatefulWidget 
{
  final Widget child;
  const HandleNotificationInteractions({super.key, required this.child});

  @override
  State<HandleNotificationInteractions> createState() => _HandleNotificationInteractionsState();
}

class _HandleNotificationInteractionsState extends State<HandleNotificationInteractions> 
{
  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async 
  {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }
  
  void _handleMessage(RemoteMessage message) 
  {
    context.read<NotificationsBloc>()
      .handleRemoteMessage(message);

    final messageId = message.messageId?.replaceAll(':', '').replaceAll('%', '');
    appRouter.push('/push-details/$messageId');
  }

  @override
  void initState() 
  {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) 
  {
    return widget.child;
  }
}