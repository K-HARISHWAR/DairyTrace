import 'package:geolocator/geolocator.dart';


class LocationServiceException implements Exception {
  final String message;
  final bool isPermanent;

  LocationServiceException(this.message, {this.isPermanent = false});

  @override
  String toString() => message;
}

class LocationService {
  /// Checks and requests location permissions.
  /// Throws [LocationServiceException] with an explanation if denied.
  static Future<void> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Location services are disabled. Please enable them in settings to improve accuracy.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Explain why we need location before requesting if we wanted to show a pre-prompt
      // Here we directly request.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException(
          'Location permission was denied. Cannot fetch GPS coordinates.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permissions are permanently denied. Please enable them in app settings.',
        isPermanent: true,
      );
    }
  }

  /// Gets the current location if available.
  /// Does not block essential operations; returns null if unavailable.
  static Future<Position?> getCurrentPosition() async {
    try {
      await checkAndRequestPermission();
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } on LocationServiceException catch (e) {
      print('Location skipped: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error fetching location: $e');
      return null;
    }
  }
}
