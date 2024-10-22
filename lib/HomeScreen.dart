import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'dart:async';

import 'package:offline_geolocator/tripProvider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();

    _handleLocationPermission();
  }

  // Request location permission and start tracking if permission is granted
  Future<void> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show a dialog or message
        _showPermissionDeniedDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, handle accordingly (like redirecting to app settings)
      _showPermissionDeniedForeverDialog();
      return;
    }

    // Check if the location services are enabled
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      _showLocationServiceDisabledDialog();
    } else {
      _startTracking(); // Start tracking if location services are enabled
    }
  }

  // Automatically listen for GPS updates
  void _startTracking() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Minimum distance to trigger an update (in meters)
      ),
    ).listen((Position position) {
      List<double> newCoordinates = [position.latitude, position.longitude];
      ref
          .read(tripProvider.notifier)
          .updateCoordinates(newCoordinates); // Update coordinates in provider
    });
  }

  // Stop tracking when the widget is disposed
  void _stopTracking() {
    _positionStream?.cancel();
  }

  @override
  void dispose() {
    _stopTracking(); // Stop GPS tracking when widget is disposed
    super.dispose();
  }

  // Dialog for permission denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Denied'),
        content:
            Text('The app needs location permission to function properly.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Dialog for permission denied forever
  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Permanently Denied'),
        content:
            Text('You need to enable location permission from app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Dialog for location services disabled
  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Services Disabled'),
        content:
            Text('Please enable location services to track your distance.'),
        actions: [
          TextButton(
            onPressed: () =>
                Geolocator.openLocationSettings(), // Open location settings
            child: Text('Enable Location'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Distance Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Coordinates: ${tripState.currentCoordinates?[0]}, ${tripState.currentCoordinates?[1]}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Distance Traveled: ${tripState.totalDistance.toStringAsFixed(2)} km',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
