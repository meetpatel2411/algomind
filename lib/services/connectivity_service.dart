import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  // Singleton
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  void initialize() {
    // Initial check
    _checkConnection();

    // Listen to network changes
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _checkConnection();
    });
  }

  DateTime _lastOnlineTime = DateTime.now();
  DateTime get lastOnlineTime => _lastOnlineTime;

  bool _isConnected = true; // Default to true, but update immediately on init
  bool get isConnected => _isConnected;

  Future<void> _checkConnection() async {
    bool isConnected = await InternetConnectionChecker.instance.hasConnection;
    _isConnected = isConnected;
    if (isConnected) {
      _lastOnlineTime = DateTime.now();
    }
    _connectionStatusController.add(isConnected);
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
