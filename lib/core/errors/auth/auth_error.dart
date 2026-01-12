import '../app_error/app_error.dart';

class AuthError extends AppError {
  const AuthError({required super.message, super.code});
}
