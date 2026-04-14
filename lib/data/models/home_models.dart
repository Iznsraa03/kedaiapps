/// Model event dari API backend.
class EventModel {
  final int id;
  final String title;
  final String description;
  final String eventType;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool registrationOpen;
  final String? imageUrl;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventType,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.registrationOpen,
    this.imageUrl,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      eventType: json['event_type'] as String? ?? '',
      location: json['location'] as String? ?? '',
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ??
          DateTime.now(),
      isActive: json['is_active'] as bool? ?? false,
      registrationOpen: json['registration_open'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
    );
  }

  /// Full URL untuk image (prefix base URL backend)
  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    // Jika sudah berupa http URL, gunakan langsung
    if (imageUrl!.startsWith('http')) return imageUrl;
    return 'https://backend.kedai.or.id/$imageUrl';
  }

  /// Label badge event type
  String get typeLabel {
    switch (eventType) {
      case 'registration':
        return 'Pendaftaran';
      case 'seminar':
        return 'Seminar';
      case 'workshop':
        return 'Workshop';
      default:
        return eventType;
    }
  }
}

/// Model sederhana untuk item berita IT (placeholder).
class NewsItem {
  final String title;
  final String source;
  final String category;
  final String publishedAt;
  final String? imageUrl;
  final String url;

  const NewsItem({
    required this.title,
    required this.source,
    required this.category,
    required this.publishedAt,
    this.imageUrl,
    required this.url,
  });
}
