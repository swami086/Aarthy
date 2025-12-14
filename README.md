# Safe Space App

Mentoring for the real you.

## Setup Instructions
1. Clone repository
2. Run `flutter pub get`
3. Copy `.env.example` to `.env`
4. Add Supabase credentials to `.env`
5. Run `flutter create .` to generate platform-specific code (Android/iOS) if missing.
6. Run `flutter run`

## Project Architecture
This project follows an MVVM (Model-View-ViewModel) architecture:
- **Models**: Data entities and JSON serialization
- **Views**: UI screens and widgets
- **ViewModels**: State management logic using Riverpod
- **Services**: Backend API calls and data sourcing

## Folder Structure
- `lib/models`: Data classes
- `lib/views`: UI layer
- `lib/viewmodels`: Business logic
- `lib/services`: External data services
- `lib/utils`: Helpers, constants, theme

## Development Guidelines
- Always use `AppColors` for styling
- Follow the directory structure when adding new features
