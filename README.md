# EVORA — AI-Based Intelligent Event & Vendor Management System

A cross-platform mobile application built with **Flutter** for event organizers and vendors, backed by a **FastAPI** backend, **Supabase** PostgreSQL database, and a companion **Next.js Admin Web Dashboard**.

---

## 🏗️ Final Architecture

```
┌─────────────────────────────────────┐     ┌──────────────────────────────┐
│   Flutter Mobile App (Android/iOS)  │     │  Next.js Admin Web Dashboard │
│                                     │     │     admin.planzo.com         │
│  ✅ Organizer Module                │     │                              │
│  ✅ Vendor Module                   │     │  ✅ Vendor Approvals         │
│  🔗 Admin → url_launcher redirect   │────▶│  ✅ User Management          │
│                                     │     │  ✅ Category Management      │
└──────────────┬──────────────────────┘     │  ✅ Analytics                │
               │                            │  ✅ Blog Management          │
               │  Shared REST APIs          └──────────────┬───────────────┘
               ▼                                           │
┌──────────────────────────────────────────────────────────▼───────────────┐
│                    FastAPI Backend (Shared API Layer)                      │
│          Auth │ Events │ Vendors │ Bookings │ Budget │ Admin APIs          │
└──────────────────────────────────────────────────────────┬───────────────┘
                                                           │
                                                           ▼
                                              ┌────────────────────────┐
                                              │  Supabase (PostgreSQL) │
                                              │  Shared Database       │
                                              └────────────────────────┘
```

> **Admin Design Decision:** Administrative workflows are handled through a dedicated web dashboard because admin operations are management-heavy and better optimized for desktop/web interfaces. The mobile app retains the Admin role option — tapping it launches `admin.planzo.com` in the external browser via `url_launcher`.

---

## 📱 Mobile App — Role Flow

| Role | Mobile Flow |
|------|------------|
| **Organizer** | Role Selection → Login → Organizer Dashboard (mobile) |
| **Vendor** | Role Selection → Login → Vendor Home (mobile) |
| **Admin** | Role Selection → Login → `launchUrl('https://admin.planzo.com')` → external browser |

### Admin Redirect Implementation

```dart
await launchUrl(
  Uri.parse('https://admin.planzo.com'),
  mode: LaunchMode.externalApplication,
);
```

---

## ✨ Features

### Organizer Module (Mobile)
- Multi-event creation with type selection (Wedding / Birthday / Corporate)
- AI Budget Recommendation Engine with categorical allocation
- **Nanban AI Chatbot** — on-device NLP intent engine
- 13-category Vendor Marketplace with shortlisting & booking
- Event checklist / task management
- In-app organizer ↔ vendor messaging

### Vendor Module (Mobile)
- Portfolio & pricing management
- Booking accept/decline pipeline
- Service calendar view
- Direct messaging with organizers

### Admin Dashboard (Next.js — Web)
- Vendor approval / rejection queue
- User registry management
- Service category configuration
- Platform analytics & revenue metrics
- Blog / content management

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | Flutter 3.x / Dart |
| State Management | Provider (MVVM) |
| Admin Dashboard | Next.js |
| Backend API | FastAPI (Python) |
| Database | Supabase (PostgreSQL) |
| Auth | Supabase Auth (JWT) |

### Flutter Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  provider: ^6.1.5       # MVVM state management
  url_launcher: ^6.3.1   # Admin web dashboard redirect
  google_fonts: ^8.0.2   # Typography
  flutter_svg: ^2.2.4    # Vector graphics
  intl: ^0.20.2          # Currency & date formatting
  animations: ^2.1.1     # Material 3 transitions
  shimmer: ^3.0.0        # Skeleton loading states
  flutter_staggered_animations: ^1.1.1  # List animations
  image_picker: ^1.2.2   # Profile photo selection
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.19+
- Dart 3.3+
- Android Studio / VS Code

### Run the mobile app

```bash
flutter pub get
flutter run
```

### Test Credentials

| Role | Email | Password |
|------|-------|----------|
| Organizer | organizer@gmail.com | organizer123 |
| Vendor | vendor@gmail.com | vendor123 |
| Admin | admin@gmail.com | admin123 → opens browser |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry + MultiProvider setup
├── providers/
│   ├── user_provider.dart       # Auth + role management
│   ├── event_provider.dart      # Event CRUD
│   ├── vendor_provider.dart     # Vendor marketplace
│   ├── budget_provider.dart     # Budget engine
│   ├── task_provider.dart       # Checklist tasks
│   └── admin_provider.dart      # Admin state
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart    # Login + Admin url_launcher redirect
│   │   └── signup_screen.dart
│   ├── role_selection_screen.dart  # Role picker (WEB badge on Admin)
│   ├── organizer/               # Organizer module screens
│   ├── vendor/                  # Vendor module screens
│   └── admin/                   # (Legacy — Admin now uses web dashboard)
├── widgets/                     # Shared UI components
└── theme/                       # AppTheme + ThemeProvider
```

---

## 📄 Documentation

Full project report: [`Synora_Project_Report.html`](./Synora_Project_Report.html)
- Open in a browser and use **Print → Save as PDF** for the report export.
