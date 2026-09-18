import 'api_failure.dart';

sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T value) ok,
    required R Function(ApiFailure failure) err,
  }) =>
      switch (this) {
        Ok<T>(:final value) => ok(value),
        Err<T>(:final failure) => err(failure),
      };
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);

  Result<R> map<R>(R Function(T) f) => Ok<R>(f(value));
}

final class Err<T> extends Result<T> {
  final ApiFailure failure;
  const Err(this.failure);

  Result<R> map<R>(R Function(T) f) => Err<R>(failure);
}
