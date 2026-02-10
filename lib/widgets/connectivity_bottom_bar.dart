import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/connectivity_service.dart';

class ConnectivityBottomBar extends StatelessWidget {
  const ConnectivityBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine background color based on theme (using surface/background colors)
    // We want it to blend in with the bottom of the screen but stand out enough as a footer.
    // Ideally it sits inside a SafeArea at the bottom.

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode
        ? const Color(0xff94a3b8)
        : const Color(0xff64748b);
    final Color bgColor = isDarkMode
        ? const Color(0xff1e293b)
        : Colors.white; // Surface color

    return Container(
      width: double.infinity,
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: SafeArea(
        top: false,
        child: StreamBuilder<bool>(
          stream: ConnectivityService().connectionStatus,
          initialData: ConnectivityService().isConnected,
          builder: (context, snapshot) {
            final isOnline = snapshot.data ?? true;
            final lastOnline = ConnectivityService().lastOnlineTime;

            String statusText;
            Color statusColor;

            if (isOnline) {
              statusText = 'Online • Synced';
              statusColor = const Color(0xff10b981); // Green
            } else {
              final timeStr =
                  "${lastOnline.hour > 12 ? lastOnline.hour - 12 : (lastOnline.hour == 0 ? 12 : lastOnline.hour)}:${lastOnline.minute.toString().padLeft(2, '0')} ${lastOnline.hour >= 12 ? 'PM' : 'AM'}";
              statusText = 'Offline • Last active $timeStr';
              statusColor = Colors.grey;
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
