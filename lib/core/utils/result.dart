import '../errors/failure.dart';

/// Outcome of a repository or use-case call: either a value or a [Failure].
sealed class Result<T> {
  const Result();

  /// Runs [action] and converts any thrown error into a [FailureResult].
  static Future<Result<T>> guard<T>(Future<T> Function() action) async {
    try {
      return Success<T>(await action());
    } catch (error) {
      return FailureResult<T>(Failure.fromException(error));
    }
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;
}
