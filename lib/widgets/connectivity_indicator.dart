import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

class ConnectivityIndicator extends StatefulWidget {
  final Widget child;

  const ConnectivityIndicator({super.key, required this.child});

  @override
  State<ConnectivityIndicator> createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator> {
  bool _isOffline = false;
  bool _showBackOnline = false;

  @override
  void initState() {
    super.initState();
    ConnectivityService().connectionStatus.listen((isConnected) {
      if (mounted) {
        setState(() {
          if (!isConnected) {
            _isOffline = true;
            _showBackOnline = false;
          } else if (_isOffline) {
            // Was offline, now online -> Show "Back Online" briefly
            _isOffline = false;
            _showBackOnline = true;
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _showBackOnline = false;
                });
              }
            });
          } else {
            // Normal online state, do nothing
            _isOffline = false;
            _showBackOnline = false;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _OfflineBanner(
              message: 'No Internet Connection',
              color: Color(0xffef4444), // Red
              icon: Icons.wifi_off_rounded,
            ),
          ),
        if (_showBackOnline)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _OfflineBanner(
              message: 'Back Online',
              color: Color(0xff10b981), // Green
              icon: Icons.wifi_rounded,
            ),
          ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const _OfflineBanner({
    required this.message,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      color: color,
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
