import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Memeriksa dan meminta izin lokasi.
  /// Mengembalikan `true` jika izin diberikan.
  static Future<bool> handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Cek izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Mendapatkan posisi saat ini.
  static Future<Position?> getCurrentPosition() async {
    final hasPermission = await handlePermission();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    );
  }

  /// Menghitung jarak (meter) antara posisi device dan lokasi branch.
  static double calculateDistance({
    required double deviceLat,
    required double deviceLng,
    required double branchLat,
    required double branchLng,
  }) {
    return Geolocator.distanceBetween(deviceLat, deviceLng, branchLat, branchLng);
  }

  /// Mengecek apakah device berada dalam radius branch.
  /// [radiusInMeters] = radius cabang dalam satuan meter.
  /// Mengembalikan `({bool isInRadius, double distance, String? error})`.
  static Future<LocationCheckResult> checkRadius({
    required double branchLat,
    required double branchLng,
    required int radiusInMeters,
  }) async {
    try {
      // Cek layanan lokasi
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationCheckResult(isInRadius: false, distance: 0, error: 'Layanan lokasi tidak aktif. Aktifkan GPS Anda.');
      }

      // Cek & minta izin
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationCheckResult(
            isInRadius: false,
            distance: 0,
            error: 'Izin lokasi ditolak. Berikan izin lokasi untuk absensi.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationCheckResult(
          isInRadius: false,
          distance: 0,
          error: 'Izin lokasi ditolak permanen. Buka Pengaturan untuk mengaktifkan.',
        );
      }

      // Dapatkan posisi GPS asli
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
      );

      // override position data untuk testing
      // Ganti dengan position.latitude & position.longitude untuk production
      // double deviceLat = -6.937350; // position.latitude;
      // double deviceLng = 107.712750; // position.longitude;

      final deviceLat = position.latitude;
      final deviceLng = position.longitude;

      // Hitung jarak
      final distance = Geolocator.distanceBetween(deviceLat, deviceLng, branchLat, branchLng);

      return LocationCheckResult(
        isInRadius: distance <= radiusInMeters,
        distance: distance,
        deviceLat: deviceLat,
        deviceLng: deviceLng,
      );
    } catch (e) {
      return LocationCheckResult(isInRadius: false, distance: 0, error: 'Gagal mendapatkan lokasi: ${e.toString()}');
    }
  }
}

/// Model hasil pengecekan radius lokasi.
class LocationCheckResult {
  final bool isInRadius;
  final double distance;
  final String? error;

  /// Koordinat GPS device saat pengecekan dilakukan.
  /// Null jika gagal mendapatkan lokasi.
  final double? deviceLat;
  final double? deviceLng;

  LocationCheckResult({required this.isInRadius, required this.distance, this.error, this.deviceLat, this.deviceLng});
}
