import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/database_service.dart';
import 'widgets/connectivity_indicator.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  final String uid;

  const NotificationsScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundLight = const Color(0xfff6f7f8);
    final Color backgroundDark = const Color(0xff101722);
    final Color bgColor = isDarkMode ? backgroundDark : backgroundLight;
    final Color surfaceColor = isDarkMode
        ? const Color(0xff1e293b)
        : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xff1e293b);
    final Color subTextColor = isDarkMode
        ? const Color(0xff94a3b8)
        : const Color(0xff64748b);
    final Color borderColor = isDarkMode
        ? const Color(0xff334155)
        : const Color(0xfff1f5f9);
    final Color primaryColor = const Color(0xff0f68e6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.lexend(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ConnectivityIndicator(
        child: StreamBuilder<QuerySnapshot>(
          stream: DatabaseService().getNotifications(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: GoogleFonts.lexend(color: Colors.red),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 64,
                      color: subTextColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: GoogleFonts.lexend(
                        color: subTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: docs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                return _buildNotificationCard(
                  data,
                  surfaceColor,
                  textColor,
                  subTextColor,
                  borderColor,
                  primaryColor,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> data,
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    Color primaryColor,
  ) {
    final String title = data['title'] ?? 'Notification';
    final String body = data['body'] ?? '';
    final String type = data['type'] ?? 'announcement';
    final bool isRead = data['isRead'] ?? false;
    final Timestamp? timestamp = data['timestamp'] as Timestamp?;
    final String timeStr = timestamp != null
        ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
        : '';

    IconData icon;
    Color iconColor;

    switch (type) {
      case 'exam':
        icon = Icons.assignment_outlined;
        iconColor = Colors.orange;
        break;
      case 'attendance':
        icon = Icons.calendar_today_outlined;
        iconColor = Colors.red;
        break;
      default:
        icon = Icons.campaign_outlined;
        iconColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    color: subTextColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timeStr,
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: subTextColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
