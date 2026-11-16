import 'package:flutter/material.dart';
import '../models/content_item.dart';
import '../services/content_service.dart';
import '../utils/date_utils.dart';
import 'admin_screen.dart';
import 'search_screen.dart';
import 'materials_screen.dart';
import 'announcements_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = ContentService();
  late Future<List<ContentItem>> future;

  @override
  void initState() {
    super.initState();
    future = service.fetchContent();
  }

  Future<void> refresh() async {
    setState(() => future = service.fetchContent());
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('College Connect',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'admin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings_outlined),
                    SizedBox(width: 8),
                    Text('Admin'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<ContentItem>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorView(
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onRetry: refresh,
            );
          }

          final items = snapshot.data ?? [];
          final announcements =
              items.where((x) => x.type == 'announcement').take(5).toList();
          final materials =
              items.where((x) => x.type == 'material').take(5).toList();

          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text('Search announcements, notes, links...'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _Header(
                  title: 'Latest Announcements',
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AnnouncementsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (announcements.isEmpty)
                  const _Empty(text: 'No announcements yet.')
                else
                  ...announcements.map((x) => _AnnouncementCard(item: x)),
                const SizedBox(height: 18),
                _Header(
                  title: 'Recent Study Materials',
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MaterialsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (materials.isEmpty)
                  const _Empty(text: 'No study materials yet.')
                else
                  ...materials.map(
                    (x) => _MaterialCard(
                      item: x,
                      onOpen: () => _openLink(context, x.link),
                    ),
                  ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'One place for your class announcements and study links.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openLink(BuildContext context, String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _Header({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ],
      );
}

class _AnnouncementCard extends StatelessWidget {
  final ContentItem item;
  const _AnnouncementCard({required this.item});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: CircleAvatar(
            child: Icon(item.important
                ? Icons.priority_high
                : Icons.campaign_outlined),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (item.important)
                const Icon(Icons.star, size: 18),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              '${item.description}\n${formatDate(item.date)}',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
}

class _MaterialCard extends StatelessWidget {
  final ContentItem item;
  final VoidCallback onOpen;
  const _MaterialCard({required this.item, required this.onOpen});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.link_outlined),
          ),
          title: Text(item.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${item.category}\n${formatDate(item.date)}'),
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: onOpen,
          ),
        ),
      );
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty({required this.text});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Center(child: Text(text)),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
}
