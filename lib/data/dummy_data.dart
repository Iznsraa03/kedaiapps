import 'models/home_models.dart';
import 'models/materi_model.dart';

// ──────────────────────────────────────────────────────────
// DUMMY DATA: Event
// Representasi response dari GET /events
// ──────────────────────────────────────────────────────────

final List<EventModel> dummyEvents = [
  EventModel(
    id: 1,
    title: 'Buka Puasa Bersama KDCW',
    description:
        'Kegiatan buka puasa bersama seluruh anggota KDCW, dengan berbagai acara seru dan makan malam bersama. Terbuka untuk semua anggota aktif dan alumni.',
    eventType: 'gathering',
    location: 'Aula Universitas Widyatama, Bandung',
    startDate: DateTime(2026, 4, 28, 17, 0),
    endDate: DateTime(2026, 4, 28, 21, 0),
    isActive: true,
    registrationOpen: true,
    imageUrl: null,
  ),
  EventModel(
    id: 2,
    title: 'Workshop Flutter & Dart untuk Pemula',
    description:
        'Workshop intensif belajar Flutter dari dasar hingga deployment. Dibimbing langsung oleh praktisi berpengalaman di industri teknologi.',
    eventType: 'workshop',
    location: 'Lab Komputer Gedung B, Lantai 3',
    startDate: DateTime(2026, 5, 10, 9, 0),
    endDate: DateTime(2026, 5, 10, 17, 0),
    isActive: true,
    registrationOpen: true,
    imageUrl: null,
  ),
  EventModel(
    id: 3,
    title: 'Seminar Keamanan Siber 2026',
    description:
        'Seminar membahas tren terbaru keamanan siber, ancaman digital, dan strategi perlindungan data di era AI. Hadirkan para pakar dari industri.',
    eventType: 'seminar',
    location: 'Auditorium Utama, Kampus Pusat',
    startDate: DateTime(2026, 5, 20, 13, 0),
    endDate: DateTime(2026, 5, 20, 16, 30),
    isActive: true,
    registrationOpen: false,
    imageUrl: null,
  ),
  EventModel(
    id: 4,
    title: 'Hackathon Internal KDCW 2026',
    description:
        'Kompetisi programming 24 jam untuk anggota KDCW. Tema: "Inovasi Digital untuk Masyarakat". Hadiah menarik untuk tiga tim terbaik.',
    eventType: 'competition',
    location: 'Gedung Teknik Informatika, Lantai 5',
    startDate: DateTime(2026, 6, 14, 8, 0),
    endDate: DateTime(2026, 6, 15, 8, 0),
    isActive: true,
    registrationOpen: true,
    imageUrl: null,
  ),
  EventModel(
    id: 5,
    title: 'Pelantikan Anggota Baru Angkatan XXIII',
    description:
        'Pelantikan resmi anggota baru KDCW angkatan XXIII. Acara ini menandai bergabungnya resmi anggota baru dalam keluarga besar KDCW.',
    eventType: 'ceremony',
    location: 'Aula Pascasarjana, Gedung Rektorat',
    startDate: DateTime(2026, 6, 28, 10, 0),
    endDate: DateTime(2026, 6, 28, 13, 0),
    isActive: false,
    registrationOpen: false,
    imageUrl: null,
  ),
];

// ──────────────────────────────────────────────────────────
// DUMMY DATA: Materi
// Representasi response dari GET /materials
// ──────────────────────────────────────────────────────────

final List<MateriModel> dummyMateri = [
  MateriModel(
    id: 1,
    title: 'Pengantar Pemrograman Dart',
    description:
        'Materi dasar pemrograman Dart: variabel, tipe data, fungsi, OOP, dan null safety. Cocok untuk pemula.',
    category: 'Programming',
    fileType: 'pdf',
    author: 'Divisi Akademik KDCW',
    publishedAt: DateTime(2026, 3, 15),
    viewCount: 128,
    isNew: false,
  ),
  MateriModel(
    id: 2,
    title: 'Arsitektur Layered Flutter (Clean Architecture)',
    description:
        'Panduan implementasi clean architecture di Flutter: UI, Logic, dan Data layer dengan contoh kode nyata.',
    category: 'Mobile Dev',
    fileType: 'pdf',
    author: 'Tim Flutter KDCW',
    publishedAt: DateTime(2026, 4, 2),
    viewCount: 204,
    isNew: true,
  ),
  MateriModel(
    id: 3,
    title: 'Ethical Hacking: Pentest Dasar',
    description:
        'Pengenalan ethical hacking, metodologi pentest, tools populer (Nmap, Burp Suite, Metasploit), dan praktik lab.',
    category: 'Keamanan',
    fileType: 'video',
    fileUrl: 'https://youtube.com',
    author: 'Divisi Cybersecurity',
    publishedAt: DateTime(2026, 3, 22),
    viewCount: 356,
    isNew: false,
  ),
  MateriModel(
    id: 4,
    title: 'Database Design & SQL Lanjutan',
    description:
        'Normalisasi database, query optimasi, stored procedure, trigger, dan indexing untuk aplikasi skala produksi.',
    category: 'Database',
    fileType: 'doc',
    author: 'Divisi Backend KDCW',
    publishedAt: DateTime(2026, 4, 10),
    viewCount: 89,
    isNew: true,
  ),
  MateriModel(
    id: 5,
    title: 'REST API Design Best Practices',
    description:
        'Panduan merancang REST API yang scalable: versioning, authentication, error handling, CORS, dan dokumentasi Swagger.',
    category: 'Backend',
    fileType: 'link',
    fileUrl: 'https://kedai.or.id/materi/rest-api',
    author: 'Tim Backend KDCW',
    publishedAt: DateTime(2026, 4, 18),
    viewCount: 147,
    isNew: true,
  ),
  MateriModel(
    id: 6,
    title: 'Machine Learning Fundamentals',
    description:
        'Dasar-dasar machine learning: supervised vs unsupervised learning, regresi, klasifikasi, dan neural network sederhana.',
    category: 'AI/ML',
    fileType: 'pdf',
    author: 'Divisi Riset & Inovasi',
    publishedAt: DateTime(2026, 2, 28),
    viewCount: 412,
    isNew: false,
  ),
  MateriModel(
    id: 7,
    title: 'Container & Docker untuk Developer',
    description:
        'Pengenalan containerization, Dockerfile, docker-compose, dan deployment ke cloud menggunakan container.',
    category: 'DevOps',
    fileType: 'video',
    fileUrl: 'https://youtube.com',
    author: 'Divisi Infrastruktur',
    publishedAt: DateTime(2026, 3, 5),
    viewCount: 231,
    isNew: false,
  ),
  MateriModel(
    id: 8,
    title: 'Git Workflow untuk Tim',
    description:
        'Git branching strategy, pull request workflow, code review, dan CI/CD dasar untuk kolaborasi tim development.',
    category: 'DevOps',
    fileType: 'pdf',
    author: 'Tim DevOps KDCW',
    publishedAt: DateTime(2026, 4, 20),
    viewCount: 178,
    isNew: true,
  ),
];
