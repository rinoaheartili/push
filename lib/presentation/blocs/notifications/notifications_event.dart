part of 'notifications_bloc.dart';

abstract class NotificationsEvent {
  const NotificationsEvent();
}

class NotificationStatusChanged extends NotificationsEvent {
  final AuthorizationStatus status;
  NotificationStatusChanged(this.status);
}

class NotificationReceived extends NotificationsEvent {
  final PushMessage pushMessage;
  NotificationReceived(this.pushMessage);
}

class LoadStoredNotifications extends NotificationsEvent {}

class ClearNotifications extends NotificationsEvent {}

class DeleteNotification extends NotificationsEvent {
  final String messageId;
  DeleteNotification(this.messageId);
}

class MarkNotificationAsRead extends NotificationsEvent {
  final String messageId;
  const MarkNotificationAsRead(this.messageId);
}

class MarkAllAsRead extends NotificationsEvent {}
