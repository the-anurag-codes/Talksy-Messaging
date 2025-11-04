# Chat Application - Flutter

A professional chat application built with **Clean Architecture**, **BLoC** pattern, and **SOLID principles**.

## Architecture

This project follows **Clean Architecture** with clear separation of concerns:

```
lib/
├── core/                   # Core utilities and base classes
│   ├── constants/          # App-wide constants
│   ├── errors/             # Error handling (Failures & Exceptions)
│   ├── theme/              # Theme configuration
│   └── di/                 # Dependency injection setup
│
├── features/               # Feature modules
│   ├── auth/               # Authentication feature
│   │   ├── data/           # Data layer
│   │   │   ├── datasources/    # Remote data sources (Firebase)
│   │   │   ├── models/         # Data models
│   │   │   └── repositories/   # Repository implementations
│   │   ├── domain/         # Domain layer
│   │   │   ├── entities/       # Business entities
│   │   │   ├── repositories/   # Repository interfaces
│   │   │   └── usecases/       # Business logic use cases
│   │   └── presentation/   # Presentation layer
│   │       ├── bloc/           # BLoC state management
│   │       ├── pages/          # UI screens
│   │       └── widgets/        # Reusable widgets
│   │
│   └── chat/               # Chat feature 
│       ├── data/
│       ├── domain/
│       └── presentation/
```

## Features

### Authentication
- Email & Password authentication via **Firebase Auth**
- Form validation with error handling
- Secure session management
- Auto-login on app restart
- Sign out functionality

### Real-time Chat
- **Firebase Real Time Database** connection using Firabase
- Real-time message delivery
- Message status indicators (Sending, Sent, Delivered, Failed)
- Typing indicators
- Optimistic UI updates
- Message bubbles with timestamps
- Empty state handling
- Auto-scroll to latest message

### State Management
- **BLoC pattern** with clear event/state separation
- Immutable state using Equatable
- Stream-based reactive programming
- Error handling in BLoC layer

### Clean Code Practices
- **SOLID principles** implementation
- **Dependency Injection** with GetIt
- Repository pattern for data abstraction
- Use case pattern for business logic
- Clear separation of concerns
- Modular and testable code