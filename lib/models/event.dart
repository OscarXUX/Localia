/// [WorldCupEvent] representa un evento o transmisión deportiva.
/// Ideal para mostrar qué negocios locales transmitirán el partido.
class WorldCupEvent {
  // 1. ATRIBUTOS
  final String id;
  final String matchTitle; // Ej. "México vs Argentina"[cite: 9]
  final DateTime? date;    // Fecha y hora del partido
  final String stadium;    // Lugar real del evento
  final String teamAImage; // URL de la bandera/logo del equipo A
  final String teamBImage; // URL de la bandera/logo del equipo B

  // 2. CONSTRUCTOR
  WorldCupEvent({
    required this.id,
    required this.matchTitle, //[cite: 9]
    this.date,
    this.stadium = "Por definir",
    this.teamAImage = "",
    this.teamBImage = "",
  });

  // 3. SERIALIZACIÓN (De Objeto a JSON para enviar al backend)
  Map<String, dynamic> toJson() => {
    'id': id,
    'matchTitle': matchTitle, //[cite: 9]
    'date': date?.toIso8601String(), // Formato estándar de fecha
    'stadium': stadium,
    'teamAImage': teamAImage,
    'teamBImage': teamBImage,
  };

  // 4. DESERIALIZACIÓN (De JSON a Objeto al recibir de SQL Server)
  factory WorldCupEvent.fromJson(Map<String, dynamic> json) {
    return WorldCupEvent(
      id: json['id']?.toString() ?? '',
      matchTitle: json['matchTitle'] ?? 'Partido sin título', //[cite: 9]
      
      // Parseo seguro de fechas
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      
      stadium: json['stadium'] ?? 'Por definir',
      teamAImage: json['teamAImage'] ?? '',
      teamBImage: json['teamBImage'] ?? '',
    );
  }
}