import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/content_item.dart';
import '../services/content_service.dart';
import '../utils/date_utils.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  String category = 'All';
  final categories = const [
    'All',
    'Class Notes',
    'Presentations',
    'Assignments',
    'Question Papers',
    'Study Materials',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Materials')),
      body: FutureBuilder<List<ContentItem>>(
        future: ContentService().fetchContent(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return const Center(child: Text('Could not load materials.'));
            }
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data!
              .where((x) =>
                  x.type == 'material' &&
                  (category == 'All' || x.category == category))
              .toList();

          return Column(
            children: [
              SizedBox(
                height: 60,
                child: ListView.separated(
                  padding: const EdgeInsets.all(10),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ChoiceChip(
                    label: Text(categories[i]),
                    selected: category == categories[i],
                    onSelected: (_) =>
                        setState(() => category = categories[i]),
                  ),
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('No materials found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final x = list[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const CircleAvatar(
                                  child: Icon(Icons.link_outlined)),
                              title: Text(x.title),
                              subtitle:
                                  Text('${x.category}\n${formatDate(x.date)}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.open_in_new),
                                onPressed: () => _open(x.link),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
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
