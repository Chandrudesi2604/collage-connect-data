import 'package:flutter/material.dart';
import '../models/content_item.dart';
import '../services/content_service.dart';
import '../utils/date_utils.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: FutureBuilder<List<ContentItem>>(
        future: ContentService().fetchContent(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return const Center(child: Text('Could not load announcements.'));
            }
            return const Center(child: CircularProgressIndicator());
          }
          final list =
              snapshot.data!.where((x) => x.type == 'announcement').toList();
          if (list.isEmpty) return const Center(child: Text('No announcements yet.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final x = list[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.campaign_outlined)),
                  title: Text(x.title),
                  subtitle: Text('${x.description}\n${formatDate(x.date)}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
