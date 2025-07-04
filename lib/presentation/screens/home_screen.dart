import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:push/presentation/blocs/notifications/notifications_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    setState(() {
      _fcmToken = token;
    });
    print('🔑 Token FCM: $token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: context.select(
          (NotificationsBloc bloc) => Text('${bloc.state.status}'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<NotificationsBloc>().requestPermission();
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_fcmToken != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(
                'FCM Token:\n$_fcmToken',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          const Expanded(child: _HomeView()),
        ],
      ),
    );
  }
}

class _HomeView extends StatelessWidget
{
  const _HomeView();
  
  @override
  Widget build(BuildContext context) 
  {
    final notifications = context.watch<NotificationsBloc>().state.notifications;
    
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (BuildContext context, int index) 
      {
        final notification = notifications[index];
        return ListTile(
          title: Text(notification.title),
          subtitle: Text(notification.body),
          leading: notification.imageUrl != null 
            ? Image.network(notification.imageUrl!)
            : null,
          onTap: () {
            context.push('/push-details/${notification.messageId}');
          },
        );
      },
    );
  }
}
