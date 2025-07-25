import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  static final NetworkInfo _instance = NetworkInfo._internal();
  factory NetworkInfo() => _instance;
  NetworkInfo._internal();

  final Connectivity _connectivity = Connectivity();

  Future<bool> get isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);
  }

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);
    });
  }
}
