import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class NotificationsTab extends StatefulWidget {
  final String studentNpm;

  const NotificationsTab({Key? key, required this.studentNpm}) : super(key: key);

  @override
  _NotificationsTabState createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  late Future<List<Map<String, dynamic>>> _notifications;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notifications = DatabaseHelper.instance.getStudentNotifications(widget.studentNpm);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _notifications,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final notifications = snapshot.data ?? [];

        if (notifications.isEmpty) {
          return Center(child: Text('Tidak ada notifikasi'));
        }

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final DateTime createdAt = DateTime.parse(notification['created_at']);
            final formattedDate = '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}';

            return Dismissible(
              key: Key(notification['id'].toString()),
              onDismissed: (direction) async {
                await DatabaseHelper.instance.deleteNotification(notification['id']);
                setState(() {
                  _loadNotifications();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifikasi dihapus')),
                );
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.notifications, color: Colors.orange),
                  title: Text(notification['message']),
                  subtitle: Text('Dibuat pada: $formattedDate'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            );
          },
        );
      },
    );
  }
}