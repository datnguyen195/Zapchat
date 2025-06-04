# ⚡ ZapChat - Lightning Fast Messaging App

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

> **Modern Flutter chat application với enterprise-level architecture và internationalization**

## 🚀 **Quick Start**

```bash
# Clone repository
git clone <repository-url>
cd zapchat

# Install dependencies
flutter pub get

# Setup environment
cp .env.example .env
# Edit .env với your configuration

# Run app
flutter run
```

## 📱 **Features**

### **✨ Core Features**

- 🎨 **Modern UI/UX** - Clean, responsive design
- 🌍 **Internationalization** - Google Sheets based translation management
- 🔄 **Real-time Sync** - Auto-sync translations và app data
- 🛡️ **Error Handling** - Comprehensive error management
- 📊 **Logging** - Professional logging system
- 🏗️ **Clean Architecture** - MVVM pattern với separation of concerns

### **🔧 Technical Features**

- ⚙️ **Environment Management** - Multi-environment support
- 💾 **Smart Caching** - Offline-first approach
- 🔌 **API Integration** - RESTful APIs với Dio
- 📈 **State Management** - Provider pattern
- 🧪 **Testing Ready** - Comprehensive test support

## 🏗️ **Architecture Overview**

```
lib/
├── core/                     # Core infrastructure
│   ├── app/                 # App initialization & configuration
│   ├── config/              # Environment & app configuration
│   ├── services/            # Infrastructure services
│   ├── localization/        # i18n management
│   ├── themes/              # App theming
│   ├── utils/               # Utilities & helpers
│   └── viewmodels/          # Base MVVM components
├── features/                # Feature modules
│   ├── auth/               # Authentication
│   ├── chat/               # Chat functionality
│   ├── settings/           # App settings
│   └── user/               # User management
└── routes/                 # App routing
```

## 📖 **Documentation**

### **🏛️ Architecture**

- [**App Architecture Refactor**](docs/architecture/APP_ARCHITECTURE_REFACTOR.md) - Clean architecture implementation
- [**MVVM Pattern**](docs/architecture/mvvm-pattern.md) - State management approach
- [**Dependency Injection**](docs/architecture/dependency-injection.md) - Service locator pattern

### **📚 Guides**

- [**Google Sheets Translation Management**](docs/guides/GOOGLE_SHEETS_TRANSLATION_GUIDE.md) - i18n workflow
- [**Environment Setup**](docs/guides/environment-setup.md) - Development environment
- [**Deployment Guide**](docs/guides/deployment.md) - Production deployment

### **🔌 API Documentation**

- [**API Setup Guide**](docs/api/API_SETUP_GUIDE.md) - REST API integration
- [**Service Architecture**](docs/api/service-architecture.md) - Service layer design
- [**Error Handling**](docs/api/error-handling.md) - API error management

### **🧪 Development**

- [**Testing Strategy**](docs/development/testing.md) - Unit & integration tests
- [**Code Style**](docs/development/code-style.md) - Coding conventions
- [**Contributing**](docs/development/contributing.md) - Contribution guidelines

## 🛠️ **Development Setup**

### **Prerequisites**

- Flutter SDK >= 3.7.2
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Git

### **Environment Configuration**

```env
# API Configuration
API_BASE_URL=https://api.zapchat.com
API_TIMEOUT=30000

# Google Sheets Translation
GOOGLE_SHEETS_ID=your_sheet_id_here
GOOGLE_SHEETS_GID=0

# Environment
ENVIRONMENT=development
DEBUG_MODE=true
```

### **Available Scripts**

```bash
# Development
flutter run                    # Run app in debug mode
flutter run --release         # Run in release mode

# Testing
flutter test                   # Run unit tests
flutter test integration_test/ # Run integration tests

# Build
flutter build apk             # Build Android APK
flutter build ios             # Build iOS app
flutter build web             # Build web app

# Code Generation
flutter packages pub run build_runner build --delete-conflicting-outputs

# Analysis
flutter analyze               # Static code analysis
dart format .                 # Code formatting
```

## 🌍 **Internationalization**

ZapChat sử dụng Google Sheets để quản lý translations:

1. **Setup Google Sheet** với format required
2. **Publish sheet** as CSV
3. **Configure environment** với sheet ID
4. **Auto-sync** translations on app start

**Supported Languages:**

- 🇺🇸 English (en)
- 🇻🇳 Vietnamese (vi)
- 🇯🇵 Japanese (ja) - Coming soon

## 🔧 **Tech Stack**

| Category                 | Technology                    |
| ------------------------ | ----------------------------- |
| **Framework**            | Flutter 3.7+                  |
| **Language**             | Dart 3.0+                     |
| **State Management**     | Provider                      |
| **Routing**              | GoRouter                      |
| **HTTP Client**          | Dio                           |
| **Local Storage**        | SharedPreferences             |
| **Internationalization** | Custom i18n với Google Sheets |
| **Logging**              | Custom Logger                 |
| **Environment**          | flutter_dotenv                |

## 📊 **Project Status**

- ✅ **Core Architecture** - Complete
- ✅ **API Integration** - Complete
- ✅ **Internationalization** - Complete
- ✅ **Error Handling** - Complete
- ✅ **Logging System** - Complete
- 🚧 **Chat Features** - In Development
- 🚧 **User Authentication** - In Development
- 📋 **Push Notifications** - Planned
- 📋 **Offline Support** - Planned

## 🤝 **Contributing**

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

See [Contributing Guide](docs/development/contributing.md) for detailed guidelines.

## 📝 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 **Team**

- **Development Team** - Core app development
- **Design Team** - UI/UX design
- **Translation Team** - Internationalization

## 📞 **Support**

- 📧 **Email**: support@zapchat.com
- 💬 **Discord**: [ZapChat Community](https://discord.gg/zapchat)
- 📖 **Documentation**: [docs.zapchat.com](https://docs.zapchat.com)
- 🐛 **Issues**: [GitHub Issues](https://github.com/zapchat/issues)

---

<div align="center">
  <p><strong>Built with ❤️ using Flutter</strong></p>
  <p>© 2024 ZapChat Team. All rights reserved.</p>
</div>
