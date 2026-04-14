import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/home_models.dart';
import '../theme/app_theme.dart';

/// Kartu event vertikal: thumbnail atas, konten bawah.
class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  // Warna badge berdasarkan event type
  static Color _typeBadgeColor(String type) {
    switch (type) {
      case 'registration':
        return const Color(0xFF1565C0);
      case 'seminar':
        return const Color(0xFF6A1B9A);
      case 'workshop':
        return const Color(0xFF00897B);
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _typeBadgeColor(event.eventType);
    final dateFormat = DateFormat('d MMM yyyy', 'id_ID');
    final startStr = dateFormat.format(event.startDate);
    final endStr = dateFormat.format(event.endDate);
    final isSameDay = event.startDate.day == event.endDate.day &&
        event.startDate.month == event.endDate.month &&
        event.startDate.year == event.endDate.year;
    final dateLabel = isSameDay ? startStr : '$startStr – $endStr';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──────────────────────────────────────────────
            _buildThumbnail(badgeColor),

            // ── Konten ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Lokasi
                  _iconRow(
                    Icons.location_on_outlined,
                    event.location,
                    AppTheme.subtle,
                  ),
                  const SizedBox(height: 4),

                  // Tanggal
                  _iconRow(
                    Icons.calendar_today_outlined,
                    dateLabel,
                    AppTheme.subtle,
                  ),
                  const SizedBox(height: 10),

                  // Status registrasi
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: event.registrationOpen
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: event.registrationOpen
                            ? Colors.green.shade300
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          event.registrationOpen
                              ? Icons.how_to_reg_rounded
                              : Icons.lock_outline_rounded,
                          size: 11,
                          color: event.registrationOpen
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.registrationOpen
                              ? 'Buka Pendaftaran'
                              : 'Pendaftaran Ditutup',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: event.registrationOpen
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Thumbnail: gambar jaringan atau fallback gradient dengan ikon
  Widget _buildThumbnail(Color badgeColor) {
    return Stack(
      children: [
        // Background: gambar atau gradient placeholder
        SizedBox(
          height: 130,
          width: double.infinity,
          child: event.fullImageUrl != null
              ? Image.network(
                  event.fullImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _e, _st) => _gradientPlaceholder(badgeColor),
                )
              : _gradientPlaceholder(badgeColor),
        ),

        // Badge event type kiri atas
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              event.typeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _gradientPlaceholder(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.event_note_rounded,
        size: 46,
        color: Colors.white.withValues(alpha: 0.40),
      ),
    );
  }

  Widget _iconRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: color, height: 1.3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Kartu berita IT — dipakai di horizontal scroll list.
class NewsCard extends StatelessWidget {
  final NewsItem news;
  final VoidCallback? onTap;

  const NewsCard({super.key, required this.news, this.onTap});

  // Warna aksen berdasarkan kategori
  static Color _categoryColor(String cat) {
    switch (cat) {
      case 'AI':
        return const Color(0xFF7B1FA2);
      case 'Mobile Dev':
        return const Color(0xFF0288D1);
      case 'Dev Tools':
        return const Color(0xFF00897B);
      case 'Keamanan':
        return const Color(0xFFC62828);
      case 'Hardware':
        return const Color(0xFFEF6C00);
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _categoryColor(news.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge + source
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    news.category,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  news.publishedAt,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.subtle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Accent line
            Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              news.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryDark,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Source row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.article_outlined,
                    size: 12,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  news.source,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.subtle,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
