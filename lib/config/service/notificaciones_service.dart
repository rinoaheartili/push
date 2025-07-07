import 'package:push/domain/entities/notificacion.dart';

import 'hive_service.dart';

class NotificacionesService 
{
  static Future<void> guardarNotificacion(Notificacion notificacion) async 
  {
    final box = HiveService.notificacionesBox;
    await box.add(notificacion.toJson());
  }

  static List<Notificacion> cargarNotificaciones() 
  {
    final box = HiveService.notificacionesBox;
    return box.values
        .map((e) => Notificacion.fromJson(Map<String, dynamic>.from(e)))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> eliminarNotificacion(int index) async 
  {
    final box = HiveService.notificacionesBox;
    final key = box.keyAt(index);
    await box.delete(key);
  }

  static Future<void> marcarTodasComoLeidas() async 
  {
    final box = HiveService.notificacionesBox;
    for (int i = 0; i < box.length; i++) {
      final key = box.keyAt(i);
      final noti = Map<String, dynamic>.from(box.get(key));
      noti['leido'] = true;
      await box.put(key, noti);
    }
  }
}