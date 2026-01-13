import '../app_error/app_error.dart';

class ValidationError extends AppError {
  final Map<String, String> fieldErrors;

  const ValidationError({
    required super.message,
    required this.fieldErrors,
    super.code,
  });
}
