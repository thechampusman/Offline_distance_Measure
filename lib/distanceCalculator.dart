import 'dart:math';

// Haversine formula for distance calculation
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // Earth radius in kilometers
  double dLat = _degreesToRadians(lat2 - lat1);
  double dLon = _degreesToRadians(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c; // Distance in kilometers
}

double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}
