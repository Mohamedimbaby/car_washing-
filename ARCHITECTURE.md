# Architecture Documentation

## Clean Architecture Overview

This project implements Clean Architecture, which separates concerns into distinct layers. This approach provides:
- **Independence**: Business logic is independent of frameworks, UI, and databases
- **Testability**: Business rules can be tested without UI, database, or external elements
- **Maintainability**: Changes in one layer don't affect others
- **Scalability**: Easy to add new features without breaking existing code

## Layer Structure

### 1. Domain Layer (Business Logic)

The innermost layer containing business logic and rules.

**Components:**
- **Entities**: Core business models (e.g., `UserEntity`, `VehicleEntity`, `BookingEntity`)
- **Repositories**: Abstract interfaces defining data operations
- **Use Cases**: Single-purpose business operations

**Example:**
```dart
// Entity
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  // ...
}

// Repository Interface
abstract class AuthRepository {
  ResultFuture<UserEntity> login({required String email, required String password});
}

// Use Case
class LoginUseCase {
  final AuthRepository repository;
  
  ResultFuture<UserEntity> call({required String email, required String password}) {
    return repository.login(email: email, password: password);
  }
}
```

**Rules:**
- No dependencies on outer layers
- Pure Dart code (no Flutter dependencies)
- Contains only business logic

### 2. Data Layer (Data Management)

Handles data operations and implements repository interfaces.

**Components:**
- **Models**: Data transfer objects extending domain entities
- **Data Sources**: 
  - Remote: API calls
  - Local: Cache/storage
- **Repository Implementations**: Concrete implementations of domain repositories

**Example:**
```dart
// Model
class UserModel extends UserEntity {
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

// Remote Data Source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;
  
  Future<UserModel> login({required String email, required String password}) async {
    final response = await client.dio.post('/auth/login', data: {...});
    return UserModel.fromJson(response.data['user']);
  }
}

// Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  ResultFuture<UserEntity> login({required String email, required String password}) async {
    try {
      final user = await remoteDataSource.login(email: email, password: password);
      await localDataSource.saveUser(user);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
```

**Rules:**
- Depends only on Domain layer
- Handles data transformation (JSON ↔ Models)
- Manages caching and network calls

### 3. Presentation Layer (UI)

The outermost layer containing UI and state management.

**Components:**
- **Pages**: Full-screen views
- **Widgets**: Reusable UI components
- **Cubit**: State management (business logic controller)
- **States**: UI state definitions

**Example:**
```dart
// State
abstract class AuthState extends Equatable {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final UserEntity user;
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  
  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    final result = await loginUseCase(email: email, password: password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }
}

// Page
class LoginPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacementNamed(context, AppRouter.home);
        }
      },
      builder: (context, state) {
        // UI implementation
      },
    );
  }
}
```

**Rules:**
- Depends on Domain layer only (not Data layer)
- Contains Flutter-specific code
- Maximum 90 lines per file
- Widgets as classes, not methods

## Data Flow

### Request Flow (User Action)
```
User Input → Widget → Cubit → Use Case → Repository → Data Source → API
```

### Response Flow (Data Return)
```
API → Data Source → Repository → Use Case → Cubit → Widget → UI Update
```

### Example: Login Flow
```dart
1. User taps login button
   ↓
2. LoginPage calls context.read<AuthCubit>().login()
   ↓
3. AuthCubit emits AuthLoading state
   ↓
4. AuthCubit calls LoginUseCase
   ↓
5. LoginUseCase calls AuthRepository.login()
   ↓
6. AuthRepositoryImpl calls AuthRemoteDataSource.login()
   ↓
7. AuthRemoteDataSource makes API call
   ↓
8. Response transforms: JSON → UserModel → UserEntity
   ↓
9. Either<Failure, UserEntity> returned up the chain
   ↓
10. AuthCubit emits Authenticated(user) or AuthError(message)
    ↓
11. BlocConsumer rebuilds UI based on new state
```

## State Management with Cubit

### Why Cubit?
- Simpler than Bloc (no events, just methods)
- Predictable state changes
- Easy to test
- Lightweight and performant

### Cubit Pattern
```dart
class FeatureCubit extends Cubit<FeatureState> {
  FeatureCubit({required this.useCase}) : super(FeatureInitial());
  
  Future<void> performAction() async {
    emit(FeatureLoading());
    final result = await useCase();
    result.fold(
      (failure) => emit(FeatureError(failure.message)),
      (data) => emit(FeatureSuccess(data)),
    );
  }
}
```

## Error Handling

### Failure Classes
```dart
abstract class Failure extends Equatable {
  final String message;
}

class ServerFailure extends Failure {}
class CacheFailure extends Failure {}
class NetworkFailure extends Failure {}
```

### Either Type (Functional Approach)
```dart
// Returns either a Failure (Left) or Success value (Right)
typedef ResultFuture<T> = Future<Either<Failure, T>>;

// Usage
ResultFuture<UserEntity> login() async {
  try {
    final user = await remoteDataSource.login();
    return Right(user);  // Success
  } catch (e) {
    return Left(ServerFailure(e.toString()));  // Failure
  }
}

// Handling in Cubit
result.fold(
  (failure) => emit(Error(failure.message)),  // Left case
  (user) => emit(Success(user)),               // Right case
);
```

## Dependency Injection

### Setup with GetIt
```dart
final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Core
  getIt.registerLazySingleton<DioClient>(() => DioClient(getIt()));
  
  // Feature: Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerFactory(() => AuthCubit(loginUseCase: getIt()));
}
```

### Benefits
- Loose coupling
- Easy testing (mock dependencies)
- Single responsibility
- Dependency inversion

## Feature Module Structure

Each feature follows this structure:
```
feature_name/
├── data/
│   ├── datasources/
│   │   ├── feature_remote_data_source.dart
│   │   └── feature_local_data_source.dart
│   ├── models/
│   │   └── feature_model.dart
│   └── repositories/
│       └── feature_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── feature_entity.dart
│   ├── repositories/
│   │   └── feature_repository.dart
│   └── usecases/
│       ├── get_feature_usecase.dart
│       └── create_feature_usecase.dart
└── presentation/
    ├── cubit/
    │   ├── feature_cubit.dart
    │   └── feature_state.dart
    ├── pages/
    │   └── feature_page.dart
    └── widgets/
        ├── feature_widget_1.dart
        └── feature_widget_2.dart
```

## Testing Strategy

### Unit Tests
- Test domain entities
- Test use cases
- Test repository implementations
- Test cubits

### Widget Tests
- Test individual widgets
- Test page layouts
- Test user interactions

### Integration Tests
- Test complete user flows
- Test API integration
- Test database operations

## Best Practices

1. **Single Responsibility**: Each class has one reason to change
2. **Dependency Inversion**: Depend on abstractions, not implementations
3. **Separation of Concerns**: Each layer has distinct responsibilities
4. **Code Reusability**: Shared widgets and utilities in core
5. **Immutability**: Use const constructors and final fields
6. **Type Safety**: Proper typing and null safety
7. **File Size**: Maximum 90 lines per file
8. **Widget Structure**: Classes over methods

## Conclusion

This architecture provides:
- ✅ Clear separation of concerns
- ✅ Easy to test
- ✅ Scalable and maintainable
- ✅ Independent of frameworks
- ✅ Flexible for changes
- ✅ Team-friendly codebase
