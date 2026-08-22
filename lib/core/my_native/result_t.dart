sealed class Result<T, E> {
  const Result();

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;

  T unwrap() {
    return switch (this) {
      Ok(value: final val) => val,
      Err() => throw StateError('Called `unwrap()` on Err'),
    };
  }

  E unwrapError() {
    return switch (this) {
      Err(err: final val) => val,
      Ok() => throw StateError('Called `unwrapError()` on Ok'),
    };
  }

  T getOrElse(T defaultValue) {
    return switch (this) {
      Ok(value: final val) => val,
      Err() => defaultValue,
    };
  }

  Result<R, E> map<R>(R Function(T value) transform) {
    return switch (this) {
      Ok(value: final val) => Ok(transform(val)),
      Err(err: final err) => Err(err),
    };
  }

  Result<T, F> mapError<F>(F Function(E error) transform) {
    return switch (this) {
      Ok(value: final val) => Ok(val),
      Err(err: final error) => Err(transform(error)),
    };
  }

  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) {
    return switch (this) {
      Ok(value: final val) => transform(val),
      Err(err: final err) => Err(err),
    };
  }

  R fold<R>({
    required R Function(T value) onOk,
    required R Function(E error) onErr,
  }) {
    return switch (this) {
      Ok(value: final val) => onOk(val),
      Err(err: final val) => onErr(val),
    };
  }
}

class Ok<T, E> extends Result<T, E> {
  final T value;
  const Ok(this.value);
}

class Err<T, E> extends Result<T, E> {
  final E err;
  const Err(this.err);
}
