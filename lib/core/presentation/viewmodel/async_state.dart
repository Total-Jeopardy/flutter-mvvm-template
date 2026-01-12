/// Template async state container (framework-agnostic).
/// Use this across all apps to standardize UI state.
///
/// States:
/// - UiIdle: nothing started yet
/// - UiLoading: work in progress
/// - UiData: success payload
/// - UiError: failure payload (usually AppError)
sealed class AsyncState<T> {
  const AsyncState();

  bool get isIdle => this is UiIdle<T>;
  bool get isLoading => this is UiLoading<T>;
  bool get hasData => this is UiData<T>;
  bool get hasError => this is UiError<T>;

  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error) error,
  }) {
    final self = this;

    if (self is UiIdle<T>) return idle();
    if (self is UiLoading<T>) return loading();
    if (self is UiData<T>) return data(self.value);
    if (self is UiError<T>) return error(self.error);

    throw StateError('Unhandled AsyncState');
  }
}

final class UiIdle<T> extends AsyncState<T> {
  const UiIdle();
}

final class UiLoading<T> extends AsyncState<T> {
  const UiLoading();
}

final class UiData<T> extends AsyncState<T> {
  final T value;
  const UiData(this.value);
}

final class UiError<T> extends AsyncState<T> {
  final Object error;
  const UiError(this.error);
}
