# Safe Space - Mental Health Support App

A Flutter-based mental health support application connecting mentees with mentors for guidance and support. Features real-time chat, appointment booking, and a safe, supportive community.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)

## 🌟 Features

### Core Functionality
- **👥 User Roles**: Separate experiences for mentors and mentees
- **💬 Real-Time Chat**: Text messaging with image and file attachments
- **📅 Appointment System**: Book, manage, and track mentor sessions
- **🔔 Notifications**: Local notifications for appointments and messages
- **👤 User Profiles**: Customizable profiles with expertise areas
- **🔐 Authentication**: Secure login, signup, and password recovery

### Chat Features
- Real-time message delivery using Supabase Realtime
- Image and file attachments (stored in Supabase Storage)
- Read receipts and message status tracking
- Conversation list with unread message badges
- Auto-mark messages as read when viewed
- Smart notifications (only when app is backgrounded)

### Appointment Features
- Interactive calendar-based booking
- Real-time availability checking
- Mentor schedule management
- Time slot blocking for mentors
- Appointment status tracking (pending, confirmed, completed, cancelled)
- Reminders via notifications

## 🏗️ Architecture

### Design Pattern
- **MVVM (Model-View-ViewModel)** architecture
- **Riverpod** for state management
- **Repository pattern** for data access
- Clean separation of concerns

### Project Structure
```
lib/
├── models/              # Data models
├── services/            # Business logic & API calls
│   ├── auth/
│   ├── chat/
│   ├── appointment/
│   ├── profile/
│   ├── notification/
│   └── storage/
├── viewmodels/          # State management with Riverpod
│   └── providers/
├── views/               # UI components
│   ├── screens/
│   └── widgets/
└── utils/               # Helpers, constants, themes
    ├── constants/
    ├── router/
    └── theme/
```

## 🛠️ Tech Stack

### Frontend
- **Flutter** 3.0+ - Cross-platform UI framework
- **Dart** 3.0+ - Programming language
- **Riverpod** - State management
- **GoRouter** - Declarative routing
- **flutter_chat_ui** - Pre-built chat components

### Backend
- **Supabase** - Backend-as-a-Service
  - PostgreSQL database
  - Real-time subscriptions
  - Authentication
  - Storage for files/images
  - Row Level Security (RLS)

### Key Dependencies
```yaml
dependencies:
  supabase_flutter: ^2.0.0
  flutter_riverpod: ^2.4.0
  go_router: ^13.0.0
  flutter_chat_ui: ^1.6.12
  flutter_local_notifications: ^17.0.0
  file_picker: ^8.0.0
  image_picker: ^1.0.0
  cached_network_image: ^3.3.0
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Supabase account
- Android Studio / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/swami086/Aarthy.git
   cd Aarthy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Supabase**
   - Create a new project on [supabase.com](https://supabase.com)
   - Run the SQL migration in `supabase_setup.sql`
   - Create the `chat_attachments` storage bucket
   - Configure RLS policies (see `supabase_schema.md`)

4. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your Supabase credentials:
   ```
   SUPABASE_URL=your_project_url
   SUPABASE_ANON_KEY=your_anon_key
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## 🗄️ Database Schema

### Key Tables
- `profiles` - User profile information
- `messages` - Chat messages with attachments
- `appointments` - Appointment bookings
- `reviews` - Mentor reviews and ratings

### Storage Buckets
- `avatars` - User profile pictures
- `chat_attachments` - Chat files and images

See `supabase_schema.md` for complete schema documentation.

## 🔒 Security

- Row Level Security (RLS) enabled on all tables
- Secure authentication via Supabase Auth
- Environment variables for sensitive data
- `.env` files excluded from version control
- File upload size limits enforced

## 📸 Screenshots

_Coming soon_

## 🧪 Testing

Run tests:
```bash
flutter test
```

Run analysis:
```bash
flutter analyze
```

## 📝 Documentation

- [`CHAT_IMPLEMENTATION_SUMMARY.md`](CHAT_IMPLEMENTATION_SUMMARY.md) - Complete chat system documentation
- [`VERIFICATION_FIXES.md`](VERIFICATION_FIXES.md) - Code quality improvements log
- [`supabase_schema.md`](supabase_schema.md) - Database schema reference
- [`supabase_setup.sql`](supabase_setup.sql) - Initial database setup

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Swami**
- GitHub: [@swami086](https://github.com/swami086)
- Email: swami086@gmail.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the powerful backend platform
- flutter_chat_ui contributors for the chat interface
- All open-source dependencies used in this project

## 📊 Project Stats

- **Total Files**: 270+
- **Lines of Code**: 10,000+
- **Code Quality**: ✅ 0 errors, 0 warnings
- **Architecture**: Clean MVVM
- **State Management**: Riverpod

## 🔮 Future Enhancements

- [ ] Group chat support
- [ ] Video call integration
- [ ] Advanced search and filters
- [ ] Analytics dashboard for mentors
- [ ] Push notifications (FCM integration)
- [ ] Message reactions and threading
- [ ] Dark mode support
- [ ] Multi-language support
- [ ] AI-powered mentor matching
- [ ] Resource library

## 📞 Support

For support, email swami086@gmail.com or open an issue in the GitHub repository.

---

**Made with ❤️ for mental health support**
