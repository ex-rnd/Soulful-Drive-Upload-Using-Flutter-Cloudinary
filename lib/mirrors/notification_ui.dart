// lib/mirrors/notification_ui.dart

import 'package:flutter/material.dart';
import '../slices/notification.dart';

class NotificationUI extends StatefulWidget {
  const NotificationUI({super.key});

  @override
  State<NotificationUI> createState() => _NotificationUIState();
}

class _NotificationUIState extends State<NotificationUI> {
  final service = NotificationService();

  @override
  void initState() {
    super.initState();
    // initialize notifications once
    service.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soulful'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Tap a button to send a notification:'),
            const SizedBox(height: 24),

            // Instant notification button
            ElevatedButton(
              onPressed: () {
                service.showInstantNotification(
                  id: 0,
                  title: 'Instant Alert',
                  body: 'This came right now!',
                );
              },
              child: const Text('Show Instant Notification'),
            ),
            const SizedBox(height: 16),

            // Scheduled notification button
            ElevatedButton(
              onPressed: () {
                service.scheduleReminder(
                  id: 1,
                  title: 'Scheduled Reminder',
                  body: 'This was scheduled 3 seconds ago',
                );
              },
              child: const Text('Schedule Notification (3s)'),
            ),
          ],
        ),
      ),
    );
  }
}
