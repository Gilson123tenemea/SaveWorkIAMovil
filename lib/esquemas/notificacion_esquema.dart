class Notificacion {
  final int id;
  final String detalle;
  final String fecha;
  final bool? estado;
  final String zona;
  final String trabajador;

  Notificacion({
    required this.id,
    required this.detalle,
    required this.fecha,
    required this.estado,
    required this.zona,
    required this.trabajador,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'],
      detalle: json['detalle'],
      fecha: json['fecha'],
      estado: json['estado'],
      zona: json['zona'],
      trabajador: json['trabajador'],
    );
  }
}