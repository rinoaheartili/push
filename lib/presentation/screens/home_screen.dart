import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:push/presentation/blocs/notifications/notifications_bloc.dart';

class HomeScreen extends StatefulWidget 
{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
{
  @override
  void initState() 
  {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async 
  {
    final token = await FirebaseMessaging.instance.getToken();
    
    print('Token FCM: $token');
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = context.select(
      (NotificationsBloc bloc) => bloc.state.status,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones - $authStatus'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<NotificationsBloc>().requestPermission();
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Solicitar permisos',
          ),
          IconButton(
            onPressed: () => _showClearConfirmation(context),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar notificaciones',
          ),
          IconButton(
            icon: const Icon(Icons.mark_email_read_outlined),
            tooltip: 'Marcar todas como leídas',
            onPressed: () {
                context.read<NotificationsBloc>().add(MarkAllAsRead());
            },
            ),
        ],
      ),
      body: Column(
        children: [
          const Expanded(child: _HomeView()),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar notificaciones?'),
        content: const Text('Se eliminarán todas las notificaciones almacenadas localmente.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Eliminar'),
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationsBloc>().add(ClearNotifications());
            },
          ),
        ],
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationsBloc>().state.notifications;

    if (notifications.isEmpty) {
      return const Center(
        child: Text('No hay notificaciones recibidas'),
      );
    }

    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final notification = notifications[index];

        return Dismissible(
            key: Key(notification.messageId),
            direction: DismissDirection.endToStart,
            background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) 
            {
                context.read<NotificationsBloc>().add(DeleteNotification(notification.messageId));
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notificación eliminada')),
                );
            },
            child: ListTile(
                leading: notification.imageUrl != null
                    ? Image.network(notification.imageUrl!, width: 40, height: 40, fit: BoxFit.cover)
                    : const Icon(Icons.notifications),
                title: Text(notification.title),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(notification.body),
                        Text(
                        _formatDate(notification.sentDate),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                    ],
                ),
                trailing: notification.read
                    ? const Icon(Icons.done, color: Colors.green)
                    : const Icon(Icons.markunread, color: Colors.blue),
                onTap: () {
                    context.push('/push-details/${notification.messageId}');
                },
            ),
            );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}