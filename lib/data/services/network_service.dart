import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio simple para verificar si hay conexión a internet.
class NetworkService {
  NetworkService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Devuelve true si hay al menos una interfaz con acceso a red (wifi/datos).
  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    // En connectivity_plus ^6.0.x esto devuelve List<ConnectivityResult>.
    return results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }
}
