import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/content_item.dart';
import '../services/content_service.dart';
import '../utils/date_utils.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  String query = '';

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() => query = controller.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool match(ContentItem x) =>
      query.isEmpty ||
      '${x.title} ${x.description} ${x.category}'
          .toLowerCase()
          .contains(query);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search everything...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: FutureBuilder<List<ContentItem>>(
        future: ContentService().fetchContent(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return const Center(child: Text('Could not load content.'));
            }
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data!.where(match).toList();
          if (list.isEmpty) return const Center(child: Text('No results found.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final x = list[i];
              final isMaterial = x.type == 'material';
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(isMaterial
                        ? Icons.link_outlined
                        : Icons.campaign_outlined),
                  ),
                  title: Text(x.title),
                  subtitle: Text(
                    isMaterial
                        ? '${x.category}\n${formatDate(x.date)}'
                        : '${x.description}\n${formatDate(x.date)}',
                  ),
                  isThreeLine: true,
                  trailing: isMaterial
                      ? IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => _open(x.link),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _open(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
