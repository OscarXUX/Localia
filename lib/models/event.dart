class WorldCupEvent {
  final String id;
  final String matchTitle; // Ej: México vs Brasil
  final String stadium;    // Ej: Estadio León
  final String time;       // Ej: 18:00 hrs
  final String date;

  WorldCupEvent({
    required this.id,
    required this.matchTitle,
    required this.stadium,
    required this.time,
    required this.date,
  });
}