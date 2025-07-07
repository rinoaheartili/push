import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:push/domain/entities/push_message.dart';

class HiveService {
  static const _secureKeyName = 'hive_aes_key';
  static final _secureStorage = FlutterSecureStorage();

  static Future<void> init() async 
  {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    // Registrar adapter
    Hive.registerAdapter(PushMessageAdapter());

    // Obtener o generar clave de cifrado
    String? keyString = await _secureStorage.read(key: _secureKeyName);
    Uint8List encryptionKey;

    if (keyString == null) 
    {
      final key = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _secureKeyName,
        value: base64UrlEncode(key),
      );
      encryptionKey = Uint8List.fromList(key);
    } else {
      encryptionKey = base64Url.decode(keyString);
    }

    // Registrar adaptadores si los necesitas (ej: NotificacionAdapter)
    if (!Hive.isAdapterRegistered(PushMessageAdapter().typeId)) 
    {
      Hive.registerAdapter(PushMessageAdapter());
    }

    // Abrir cajas cifradas
    await Hive.openBox<PushMessage>(
      'push_messages', 
      encryptionCipher: HiveAesCipher(encryptionKey)
    );
  }

  static Box get notificacionesBox => Hive.box('push_messages');
}
