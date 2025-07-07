class Notificacion {
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  final bool leido;

  Notificacion({
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    this.leido = false,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) => Notificacion(
        titulo: json['titulo'],
        mensaje: json['mensaje'],
        fecha: DateTime.parse(json['fecha']),
        leido: json['leido'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'mensaje': mensaje,
        'fecha': fecha.toIso8601String(),
        'leido': leido,
      };
}
