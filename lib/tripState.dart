class TripState {
  final double totalDistance;
  final List<double>?
      currentCoordinates; // Allow currentCoordinates to be null initially

  TripState({required this.totalDistance, required this.currentCoordinates});
}
