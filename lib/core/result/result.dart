import '../error/failure.dart';

sealed class Result<T> {
  const Result();

  R fold<R>(R Function(Failure failure) onError, R Function(T value) onSuccess);

  bool get isOk => this is Ok<T>;

  bool get isErr => this is Err<T>;
}

class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  R fold<R>(
    R Function(Failure failure) onError,
    R Function(T value) onSuccess,
  ) {
    return onSuccess(value);
  }
}

class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  R fold<R>(
    R Function(Failure failure) onError,
    R Function(T value) onSuccess,
  ) {
    return onError(failure);
  }
}
