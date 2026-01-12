/// One-off UI events should NOT live inside persistent state.
/// UiMessage is meant for snackbars, toasts, banners, dialogs, etc.
///
/// Template rules:
/// - ViewModels can emit UiMessage as an event.
/// - UI consumes it once, then it is cleared.
/// - Never store tokens, secrets, or stack traces in UiMessage.
sealed class UiMessage {
  final String text;

  const UiMessage(this.text);
}

final class UiInfo extends UiMessage {
  const UiInfo(super.text);
}

final class UiSuccess extends UiMessage {
  const UiSuccess(super.text);
}

final class UiWarning extends UiMessage {
  const UiWarning(super.text);
}

final class UiErrorMessage extends UiMessage {
  /// Optional code for UI analytics/debug tags (not a stack trace).
  final String? code;

  const UiErrorMessage(super.text, {this.code});
}

/// A wrapper for one-time consumable events.
/// UI calls `consume()`; after that it returns null.
final class UiEvent<T> {
  final T _value;
  bool _consumed;

  UiEvent(T value) : _value = value, _consumed = false;

  /// Returns the value only once. Future calls return null.
  T? consume() {
    if (_consumed) return null;
    _consumed = true;
    return _value;
  }

  /// Peek without consuming (use sparingly).
  T get value => _value;

  bool get isConsumed => _consumed;
}
