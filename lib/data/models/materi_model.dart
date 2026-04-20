/// Model untuk materi pembelajaran dari API backend.
class MateriModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final String fileType; // 'pdf', 'video', 'link', 'doc'
  final String? fileUrl;
  final String? thumbnailUrl;
  final String author;
  final DateTime publishedAt;
  final int viewCount;
  final bool isNew;

  const MateriModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.fileType,
    this.fileUrl,
    this.thumbnailUrl,
    required this.author,
    required this.publishedAt,
    required this.viewCount,
    required this.isNew,
  });

  factory MateriModel.fromJson(Map<String, dynamic> json) {
    return MateriModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      fileType: json['file_type'] as String? ?? 'pdf',
      fileUrl: json['file_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      author: json['author'] as String? ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? '') ??
          DateTime.now(),
      viewCount: json['view_count'] as int? ?? 0,
      isNew: json['is_new'] as bool? ?? false,
    );
  }

  /// Icon sesuai file type
  String get fileTypeIcon {
    switch (fileType) {
      case 'pdf':
        return '📄';
      case 'video':
        return '🎬';
      case 'link':
        return '🔗';
      case 'doc':
        return '📝';
      default:
        return '📁';
    }
  }

  /// Label warna untuk file type badge
  String get fileTypeLabel {
    switch (fileType) {
      case 'pdf':
        return 'PDF';
      case 'video':
        return 'Video';
      case 'link':
        return 'Link';
      case 'doc':
        return 'Dokumen';
      default:
        return fileType.toUpperCase();
    }
  }
}
