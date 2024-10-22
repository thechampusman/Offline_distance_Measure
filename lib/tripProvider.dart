import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_geolocator/tripState.dart';

import 'distanceCalculator.dart';

// Trip State Notifier
class TripNotifier extends StateNotifier<TripState> {
  TripNotifier()
      : super(TripState(totalDistance: 0.0, currentCoordinates: null));

  // Method to update coordinates and calculate distance
  void updateCoordinates(List<double> newCoordinates) {
    // If currentCoordinates is null, it's the first update, so just set it and skip distance calculation
    if (state.currentCoordinates == null) {
      state = TripState(totalDistance: 0.0, currentCoordinates: newCoordinates);
    } else {
      // Calculate distance only after the first update
      double distance = calculateDistance(
        state.currentCoordinates![0],
        state.currentCoordinates![1], // Previous coordinates
        newCoordinates[0], newCoordinates[1], // New coordinates
      );

      // Update state with the new total distance and new coordinates
      state = TripState(
        totalDistance: state.totalDistance + distance,
        currentCoordinates: newCoordinates,
      );
    }
  }
}

// Riverpod provider for TripNotifier
final tripProvider =
    StateNotifierProvider<TripNotifier, TripState>((ref) => TripNotifier());
