abstract class Logger {
  const Logger();

  void d(String message);
  void i(String message);
  void w(String message);
  void e(String message, {Object? error, StackTrace? stackTrace});
}

/// Default logger (safe for template).
/// Swap this later with Sentry/Crashlytics logger without touching other code.
class ConsoleLogger implements Logger {
  const ConsoleLogger();

  @override
  void d(String message) => _log('DEBUG', message);

  @override
  void i(String message) => _log('INFO', message);

  @override
  void w(String message) => _log('WARN', message);

  @override
  void e(String message, {Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message);
    if (error != null) _log('ERROR', 'error: $error');
    if (stackTrace != null) _log('ERROR', 'stackTrace: $stackTrace');
  }

  void _log(String level, String message) {
    // Keep as print for template simplicity.
    // Apps can replace Logger implementation globally.
    // ignore: avoid_print
    print('[$level] $message');
  }
}
