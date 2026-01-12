import '../app_error/app_error.dart';

class ValidationError extends AppError {
  final Map<String, String> fieldErrors;

  const ValidationError({
    required String message,
    required this.fieldErrors,
    String? code,
  }) : super(message: message, code: code);
}
