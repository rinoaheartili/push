import 'package:hive/hive.dart';

part 'push_message.g.dart';

@HiveType(typeId: 0)
class PushMessage 
{
  @HiveField(0)
  final String messageId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final bool read;

  @HiveField(4)
  final DateTime sentDate;

  @HiveField(5)
  final Map<String,dynamic>? data;

  @HiveField(6)
  final String? imageUrl;

  PushMessage({
    required this.messageId, 
    required this.title, 
    required this.body, 
    this.read = false,
    required this.sentDate, 
    this.data, 
    this.imageUrl
  });

  @override
  String toString() 
  {
    return '''
      PushMessage - 
        id:    $messageId
        title: $title
        body:  $body
        data:  $data
        imageUrl: $imageUrl
        sentDate: $sentDate
    ''';
  }

  PushMessage copyWith({bool? read}) => PushMessage(
    messageId: messageId,
    title: title,
    body: body,
    sentDate: sentDate,
    read: read ?? this.read, 
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushMessage &&
          runtimeType == other.runtimeType &&
          messageId == other.messageId &&
          title == other.title &&
          body == other.body &&
          sentDate == other.sentDate &&
          read == other.read;

  @override
  int get hashCode => messageId.hashCode ^ title.hashCode ^ body.hashCode ^ sentDate.hashCode ^ read.hashCode;

}
