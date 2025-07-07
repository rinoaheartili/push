import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push/domain/entities/push_message.dart';
import 'package:push/presentation/blocs/notifications/notifications_bloc.dart';

class DetailsScreen extends StatelessWidget 
{
  final String pushMessageId;

  const DetailsScreen({super.key, required this.pushMessageId});

  @override
  Widget build(BuildContext context) 
  {
    final PushMessage? message = context.watch<NotificationsBloc>().getMessageById(pushMessageId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Notificación'),
      ),
      body: message != null
          ? _DetailsView(message: message)
          : const Center(child: Text('La notificación no existe')),
    );
  }
}

class _DetailsView extends StatelessWidget 
{
  final PushMessage message;

  const _DetailsView({required this.message});

  @override
  Widget build(BuildContext context) 
  {
    final textStyles = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(message.imageUrl!, fit: BoxFit.cover),
            ),

          const SizedBox(height: 20),

          Text(
            message.title,
            style: textStyles.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Text(
            message.body,
            style: textStyles.bodyLarge,
          ),

          const SizedBox(height: 20),
          const Divider(),

          Text(
            'Fecha de recepción:',
            style: textStyles.titleMedium,
          ),
          Text(
            _formatDate(message.sentDate),
            style: textStyles.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),

          const SizedBox(height: 20),

          if (message.data != null && message.data!.isNotEmpty) ...[
            Text(
              'Datos adicionales:',
              style: textStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            ...message.data!.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text('${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text('${entry.value}')),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) 
  {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
