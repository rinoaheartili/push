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
  final DateTime sentDate;

  @HiveField(4)
  final Map<String,dynamic>? data;

  @HiveField(5)
  final String? imageUrl;

  PushMessage({
    required this.messageId, 
    required this.title, 
    required this.body, 
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

}
