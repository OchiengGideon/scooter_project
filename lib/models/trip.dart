class Trip {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double distance;
  final double cost;
  final String scooterId;
  final String? startLocation;
  final String? endLocation;

  Trip({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.distance,
    required this.cost,
    required this.scooterId,
    this.startLocation,
    this.endLocation,
  });

  Duration get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return Duration.zero;
  }
}