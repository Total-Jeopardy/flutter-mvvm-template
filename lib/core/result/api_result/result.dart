sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Object error) failure,
  }) {
    final self = this;
    if (self is Success<T>) {
      return success(self.data);
    } else if (self is Failure<T>) {
      return failure(self.error);
    }
    throw StateError('Unhandled Result state');
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final Object error;
  const Failure(this.error);
}
