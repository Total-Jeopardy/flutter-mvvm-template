abstract class AppError {
  final String message;
  final String? code;

  const AppError({required this.message, this.code});
}
