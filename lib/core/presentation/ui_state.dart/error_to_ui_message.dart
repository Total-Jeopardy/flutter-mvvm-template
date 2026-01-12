import '../../errors/app_error/app_error.dart';
import '../../errors/auth/auth_error.dart';
import '../../errors/network/network_error.dart';
import '../../errors/validation/validation_error.dart';
import 'ui_message.dart';

/// Converts core errors into user-facing UiMessages.
/// Template rule:
/// - Do NOT leak stack traces or raw server payloads to UI.
/// - Keep messages human and safe.
/// - Apps may customize wording later, but default must be sensible.
class ErrorToUiMessage {
  const ErrorToUiMessage();

  UiMessage map(Object error) {
    // If it's already an AppError, map by type.
    if (error is AppError) {
      return _mapAppError(error);
    }

    // Unknown errors (should be rare). Safe fallback.
    return const UiErrorMessage('Something went wrong. Please try again.');
  }

  UiMessage _mapAppError(AppError error) {
    // Auth issues
    if (error is AuthError) {
      return UiErrorMessage(
        error.message.isNotEmpty ? error.message : 'Authentication failed.',
        code: error.code,
      );
    }

    // Network issues
    if (error is NetworkError) {
      // Prefer friendly network message over raw exception text.
      final text = _friendlyNetworkMessage(error.message);
      return UiErrorMessage(text, code: error.code);
    }

    // Validation issues
    if (error is ValidationError) {
      // If there's a top-level message, show it.
      // Field errors are usually rendered near inputs (per screen logic).
      final msg = error.message.isNotEmpty
          ? error.message
          : 'Please check your input.';
      return UiWarning(msg);
    }

    // Default for other AppError types
    return UiErrorMessage(
      error.message.isNotEmpty
          ? error.message
          : 'Request failed. Please try again.',
      code: error.code,
    );
  }

  String _friendlyNetworkMessage(String raw) {
    final lower = raw.toLowerCase();

    // Very common cases across http/dio/socket without coupling to a package.
    if (lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('internet')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (lower.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (lower.contains('handshake') ||
        lower.contains('certificate') ||
        lower.contains('tls')) {
      return 'Secure connection failed. Please try again.';
    }

    // Safe fallback: don't echo raw error text to users.
    return 'Unable to reach the server. Please try again.';
  }
}
