# 📱 DM Todo - Flutter Todo Application

> **Aplikasi Todo List Modern** dengan Flutter - Dual Version: Advanced & Tutorial

[![Flutter Version](https://img.shields.io/badge/Flutter-3.10.1-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.10.1-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)]()

---

## 📋 Gambaran Umum

**DM Todo** adalah aplikasi Todo List yang dibangun dengan Flutter, tersedia dalam **2 versi berbeda**:

### 🚀 Versi Advanced (`TodoWebSimple`)
Aplikasi production-ready dengan fitur lengkap:
- ✅ State Management dengan **Provider**
- ✅ Database persistent dengan **SQLite**
- ✅ **Notifications** & Reminders
- ✅ **Dashboard** dengan charts & statistik
- ✅ Priority & Category system
- ✅ Modern UI/UX

### 📖 Versi Tutorial (`TutorialBasicTodoPage`)
Implementasi sederhana untuk pembelajaran (sesuai Tutorial BAB 1-12):
- ✅ State management dengan `setState()`
- ✅ Data storage sederhana (`List<String>`)
- ✅ CRUD operations basic
- ✅ UI minimalis
- ✅ Perfect untuk belajar Flutter

---

## ✨ Fitur Utama

### Versi Advanced

| Kategori | Fitur |
|----------|-------|
| **CRUD** | Create, Read, Update, Delete todo |
| **Kategorisasi** | General, Work, Personal, Shopping, Health, Education |
| **Priority** | High, Medium, Low dengan color coding |
| **Due Date** | Set deadline untuk tasks |
| **Reminders** | Scheduled notifications |
| **Dashboard** | Pie chart, statistik, progress tracking |
| **Filtering** | Filter by category & status (All/Active/Done) |
| **Persistence** | SQLite database - data tidak hilang |

### Versi Tutorial

- ✅ Tambah todo (dengan validasi)
- ✅ Tampilkan daftar todo
- ✅ Hapus todo (dengan konfirmasi)
- ✅ Empty state handling
- ✅ User feedback (SnackBar)

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.10.1 atau lebih baru
- Dart 3.10.1 atau lebih baru
- Android Studio / VS Code
- Android Emulator atau Physical Device

### Installation

1. **Clone repository**
   ```bash
   cd "d:\Kuli-Ah\Pemrograman Mobile\flutter_todo"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run aplikasi**
   ```bash
   flutter run
   ```

### Switching Between Versions

Edit `lib/main.dart`:

```dart
// Untuk versi ADVANCED (default):
home: const TodoWebSimple(),

// Untuk versi TUTORIAL:
home: const TutorialBasicTodoPage(),
```

Kemudian hot reload (`r` di terminal).

---

## 📚 Dokumentasi

### Dokumentasi Lengkap

1. **[DOKUMENTASI_ADVANCED.md](DOKUMENTASI_ADVANCED.md)** (720+ lines)
   - Arsitektur aplikasi
   - Database schema
   - State management pattern
   - Notification system
   - UI/UX components
   - Build instructions

2. **[DOKUMENTASI_TUTORIAL.md](DOKUMENTASI_TUTORIAL.md)** (630+ lines)
   - Mapping ke BAB 1-12 tutorial
   - Penjelasan kode detail
   - State flow diagrams
   - Learning path
   - Practice exercises

### Tutorial BAB 1-12

Tutorial asli mencakup:
- **BAB 1**: Overview Project
- **BAB 2**: Struktur Folder
- **BAB 3**: Entry Point (main.dart)
- **BAB 4**: Struktur UI Utama
- **BAB 5**: Model Data & State
- **BAB 6**: Form Input Todo
- **BAB 7**: Menampilkan Daftar
- **BAB 8**: Aksi Todo & UX
- **BAB 9**: Penggunaan Assets
- **BAB 10**: Konfigurasi Android
- **BAB 11**: Build APK Debug
- **BAB 12**: Build APK Release

**Lihat** `DOKUMENTASI_TUTORIAL.md` untuk implementasi lengkap!

---

## 🏗️ Struktur Project

```
flutter_todo/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── todo_web_simple.dart         # 🚀 Versi Advanced
│   ├── tutorial_basic_todo.dart     # 📖 Versi Tutorial
│   │
│   ├── models/
│   │   └── todo_model.dart          # Data model
│   │
│   ├── providers/
│   │   └── todo_provider.dart       # State management
│   │
│   ├── helpers/
│   │   ├── database_helper.dart     # SQLite helper
│   │   └── notification_helper.dart # Notification helper
│   │
│   └── widgets/
│       ├── todo_item.dart           # Todo item widget
│       ├── add_todo_dialog.dart     # Add/Edit dialog
│       ├── dashboard_chart.dart     # Pie chart
│       └── stat_card.dart           # Statistic card
│
├── android/                         # Android configuration
├── assets/                          # Assets (icons, images)
├── DOKUMENTASI_ADVANCED.md          # 📄 Advanced docs
├── DOKUMENTASI_TUTORIAL.md          # 📄 Tutorial docs
└── pubspec.yaml                     # Dependencies
```

---

## 🛠️ Technologies

### Core
- **Flutter**: ^3.10.1
- **Dart**: ^3.10.1

### State Management
- **provider**: ^6.1.1

### Database
- **sqflite**: ^2.3.0
- **path**: ^1.8.3

### Notifications
- **flutter_local_notifications**: ^18.0.1
- **timezone**: ^0.9.4
- **permission_handler**: ^11.1.0

### UI/UX
- **google_fonts**: ^6.1.0 (Outfit font)
- **fl_chart**: ^0.66.0 (Charts)
- **intl**: ^0.19.0 (Date formatting)

**Full list**: Lihat `pubspec.yaml`

---

## 📱 Screenshots

### Versi Advanced

- **Dashboard**: Pie chart, statistics, category filters
- **Add Todo**: Form lengkap dengan priority, category, due date
- **Todo List**: Modern card design dengan priority indicators
- **Notifications**: Scheduled reminders

### Versi Tutorial

- **Simple List**: Basic todo list dengan nomor urut
- **Add Form**: TextField sederhana dengan tombol tambah
- **Empty State**: Friendly empty state UI

*(Screenshots bisa ditambahkan setelah testing)*

---

## 🧪 Testing

### Manual Testing

Semua fitur telah ditest secara manual:

- ✅ CRUD operations (Create, Read, Update, Delete)
- ✅ Form validation
- ✅ Database persistence
- ✅ Category & priority filtering
- ✅ Date & time picker
- ✅ Notification scheduling
- ✅ UI responsiveness
- ✅ Error handling

**Note**: Notifications require physical device untuk full testing.

---

## 📦 Build APK

### Debug APK

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

**Lihat** `DOKUMENTASI_ADVANCED.md` untuk detail lengkap!

---

## 🎓 Learning Path

### Untuk Pemula

1. **Start dengan versi Tutorial** (`TutorialBasicTodoPage`)
2. **Baca** `DOKUMENTASI_TUTORIAL.md`
3. **Pahami** konsep StatefulWidget & setState()
4. **Coba** latihan di dokumentasi (Level 1-3)

### Untuk Lanjutan

1. **Pelajari versi Advanced** (`TodoWebSimple`)
2. **Baca** `DOKUMENTASI_ADVANCED.md`
3. **Pahami** Provider pattern, SQLite, Notifications
4. **Develop** fitur tambahan

---

## 🤝 Contributing

Project ini untuk tujuan pembelajaran. Suggestions welcome!

---

## 📞 Contact & Support

**Developer**: Telunjuk Digital DMSoft  
**Project**: DM Todo  
**Version**: 1.0.0+1

---

## 📄 License

Proprietary - © 2026 Telunjuk Digital DMSoft

---

## 🙏 Acknowledgments

- Flutter team untuk framework yang amazing
- Semua maintainers dari packages yang digunakan
- Tutorial BAB 1-12 sebagai foundation

---

## 🔗 Quick Links

- 📖 [Dokumentasi Advanced](DOKUMENTASI_ADVANCED.md)
- 📖 [Dokumentasi Tutorial](DOKUMENTASI_TUTORIAL.md)
- 🐛 [Report Issues](#)
- 💡 [Request Features](#)

---

**Happy Coding! 🚀**

*Last Updated: 2026-01-13*
