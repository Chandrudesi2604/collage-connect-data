class ContentItem {
  final String id;
  final String type; // announcement or material
  final String title;
  final String description;
  final String category;
  final String link;
  final bool important;
  final DateTime date;

  const ContentItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    required this.link,
    required this.important,
    required this.date,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'announcement',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      link: json['link']?.toString() ?? '',
      important: json['important'] == true,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
