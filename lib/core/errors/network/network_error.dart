import '../app_error/app_error.dart';

class NetworkError extends AppError {
  const NetworkError({required super.message, super.code});
}
