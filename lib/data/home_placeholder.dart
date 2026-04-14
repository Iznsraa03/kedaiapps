import 'package:kedaiapp/data/models/home_models.dart';

/// Placeholder event data — 3 item pertama.
final List<EventModel> placeholderEvents = [
  EventModel(
    id: 1,
    title: 'Buka Puasa Bersama KDCW',
    description:
        'Kegiatan buka puasa bersama seluruh anggota KDCW, dengan berbagai acara seru dan makan malam bersama.',
    eventType: 'registration',
    location: 'Aula Universitas Widyatama, Bandung',
    startDate: DateTime(2026, 3, 25, 8, 41),
    endDate: DateTime(2026, 3, 28, 8, 41),
    isActive: true,
    registrationOpen: true,
    imageUrl: null,
  ),
  EventModel(
    id: 2,
    title: 'Workshop Flutter & Dart',
    description:
        'Workshop intensif belajar Flutter dari dasar hingga deployment, dibimbing oleh praktisi berpengalaman.',
    eventType: 'workshop',
    location: 'Lab Komputer Gedung B, Lantai 3',
    startDate: DateTime(2026, 4, 10, 9, 0),
    endDate: DateTime(2026, 4, 10, 17, 0),
    isActive: true,
    registrationOpen: true,
    imageUrl: null,
  ),
  EventModel(
    id: 3,
    title: 'Seminar Keamanan Siber 2026',
    description:
        'Seminar membahas tren terbaru keamanan siber, ancaman digital, dan strategi perlindungan data.',
    eventType: 'seminar',
    location: 'Auditorium Utama, Kampus Pusat',
    startDate: DateTime(2026, 4, 20, 13, 0),
    endDate: DateTime(2026, 4, 20, 16, 30),
    isActive: true,
    registrationOpen: false,
    imageUrl: null,
  ),
];

/// Placeholder berita IT terbaru — horizontal scroll.
final List<NewsItem> placeholderNews = [
  const NewsItem(
    title: 'Google Umumkan Gemini 2.0 Ultra dengan Kemampuan Multimodal Baru',
    source: 'TechCrunch',
    category: 'AI',
    publishedAt: '2 jam lalu',
    url: 'https://techcrunch.com',
  ),
  const NewsItem(
    title:
        'Flutter 3.27 Rilis: Impeller Stabil di Android dan Performa Lebih Cepat',
    source: 'Flutter Blog',
    category: 'Mobile Dev',
    publishedAt: '5 jam lalu',
    url: 'https://flutter.dev',
  ),
  const NewsItem(
    title: 'OpenAI GPT-5 Bocor: Benchmark Baru Lampaui Semua Model Sebelumnya',
    source: 'The Verge',
    category: 'AI',
    publishedAt: '8 jam lalu',
    url: 'https://theverge.com',
  ),
  const NewsItem(
    title: 'GitHub Copilot Kini Mendukung Lebih dari 40 Bahasa Pemrograman',
    source: 'GitHub Blog',
    category: 'Dev Tools',
    publishedAt: '1 hari lalu',
    url: 'https://github.blog',
  ),
  const NewsItem(
    title: 'Serangan Ransomware Meningkat 150% di Asia Tenggara pada 2025',
    source: 'Kompas Tekno',
    category: 'Keamanan',
    publishedAt: '1 hari lalu',
    url: 'https://kompas.com',
  ),
  const NewsItem(
    title: 'Meta Rilis Ray-Ban Smart Glasses Generasi Ketiga dengan AI Onboard',
    source: 'Wired',
    category: 'Hardware',
    publishedAt: '2 hari lalu',
    url: 'https://wired.com',
  ),
];
