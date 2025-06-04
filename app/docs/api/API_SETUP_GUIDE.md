# Hướng dẫn Setup API với Dio

## Tổng quan

Dự án này đã được setup để sử dụng Dio cho HTTP client với cấu trúc clean architecture. Các thành phần chính bao gồm:

- **ApiClient**: Base client cho tất cả các HTTP request
- **Service classes**: Các service cụ thể cho từng feature
- **ServiceLocator**: Dependency injection pattern
- **Error handling**: Xử lý lỗi toàn cục
- **Environment Configuration**: Quản lý environment variables an toàn

## Cấu trúc File

```
lib/
├── core/
│   ├── config/
│   │   └── environment.dart           # Environment configuration
│   ├── models/
│   │   └── api_response.dart          # Model cho API response
│   └── services/
│       ├── api_client.dart            # Base HTTP client
│       ├── service_locator.dart       # Dependency injection
│       └── user_service.dart          # Ví dụ service
├── features/
│   └── user/
│       └── user_list_page.dart        # Ví dụ sử dụng service
├── main.dart                          # Khởi tạo ServiceLocator
├── .env                               # Environment variables (không commit)
└── .env.example                       # Template cho .env
```

## Dependencies đã thêm

```yaml
dependencies:
  dio: ^5.4.0 # HTTP client
  json_annotation: ^4.8.1 # JSON serialization annotations
  get_it: ^7.6.4 # Dependency injection
  flutter_dotenv: ^5.1.0 # Environment variables
  logger: ^2.0.2+1 # Logging framework

dev_dependencies:
  json_serializable: ^6.7.1 # JSON code generation
  build_runner: ^2.4.7 # Code generation runner
```

## Environment Setup

### 1. Tạo file .env

Copy từ template và cập nhật values:

```bash
cp .env.example .env
```

### 2. Cấu hình .env

```env
# API Configuration
API_BASE_URL=https://your-real-api.com
API_TIMEOUT=30000

# App Configuration
APP_NAME=ZapChat
APP_VERSION=1.0.0
DEBUG_MODE=true

# Environment
ENVIRONMENT=development
```

### 3. Bảo mật

- File `.env` đã được thêm vào `.gitignore`
- Không bao giờ commit file `.env`
- Sử dụng `.env.example` để share template
- Các giá trị sensitive như API keys, secrets phải được quản lý cẩn thận

## Logging System

### AppLogger Features

- **Environment-aware**: Different log levels cho từng environment
- **Production-safe**: Không log sensitive data trong production
- **Structured logging**: Có categories cho API, Performance, Error
- **Pretty formatting**: Colors và emojis trong development

### Log Levels

- **Development**: Debug, Info, Warning, Error, Fatal
- **Staging**: Info, Warning, Error, Fatal
- **Production**: Warning, Error, Fatal

### Cách sử dụng Logger

```dart
import '../../core/utils/app_logger.dart';

// Debug logs
AppLogger.debug('Debug information');

// Info logs
AppLogger.info('Application started');

// Warning logs
AppLogger.warning('This is a warning');

// Error logs
AppLogger.error('An error occurred', error, stackTrace);

// API logs (tự động từ ApiClient)
AppLogger.api('GET', '/users', statusCode: 200);

// Performance logs
AppLogger.performance('Database Query', duration);
```

## Cách sử dụng

### 1. Cấu hình Base URL

Cập nhật `baseUrl` trong `lib/core/services/api_client.dart`:

```dart
static const String baseUrl = 'https://your-api-domain.com/api';
```

### 2. Tạo Service mới

Tạo file service mới trong `lib/core/services/`:

```dart
import 'api_client.dart';

class YourService {
  final ApiClient _apiClient;

  YourService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getData() async {
    try {
      final response = await _apiClient.get('/your-endpoint');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw e;
    }
  }
}
```

### 3. Đăng ký Service

Thêm service vào `ServiceLocator` trong `lib/core/services/service_locator.dart`:

```dart
static void setup() {
  // ... existing registrations
  getIt.registerLazySingleton<YourService>(() => YourService());
}
```

### 4. Sử dụng trong Widget

```dart
class YourWidget extends StatefulWidget {
  @override
  _YourWidgetState createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  final YourService _yourService = ServiceLocator.get<YourService>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _yourService.getData();
      // Xử lý data
    } catch (e) {
      // Xử lý lỗi
    }
  }
}
```

## Các tính năng đã có

### HTTP Methods

- `GET`: Lấy dữ liệu
- `POST`: Tạo mới
- `PUT`: Cập nhật toàn bộ
- `PATCH`: Cập nhật một phần
- `DELETE`: Xóa
- `uploadFile`: Upload file

### Error Handling

- `TimeoutException`: Lỗi timeout
- `NetworkException`: Lỗi mạng
- `HttpException`: Lỗi HTTP (4xx, 5xx)
- `CancelException`: Request bị hủy
- `UnknownException`: Lỗi không xác định

### Interceptors

- **PrettyDioLogger**: Log request/response để debug
- **AuthInterceptor**: Tự động thêm token và xử lý 401

### Authentication

Để thêm authentication, uncomment và cập nhật code trong `api_client.dart`:

```dart
onRequest: (options, handler) {
  final token = getStoredToken(); // Implement function này
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  handler.next(options);
},
```

## Ví dụ đầy đủ

Xem `lib/features/user/user_list_page.dart` để biết cách sử dụng hoàn chỉnh với:

- Loading states
- Error handling
- CRUD operations
- UI feedback

## Lưu ý

1. **Base URL**: Nhớ thay đổi base URL phù hợp với API của bạn
2. **Authentication**: Implement token storage/retrieval theo nhu cầu
3. **Error Messages**: Customize error messages cho phù hợp
4. **Logging**: Tắt logging trong production build
5. **Timeout**: Có thể điều chỉnh timeout values

## Build Runner

Sau khi tạo models với json_serializable, chạy:

```bash
flutter packages pub run build_runner build
```

Hoặc để watch changes:

```bash
flutter packages pub run build_runner watch
```
