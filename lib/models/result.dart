class Result<T> {
  final bool success;
  final T? data;
  final String? message;
  final dynamic error;

  Result({
    this.success = true,
    this.data,
    this.message,
    this.error,
  });

  factory Result.success([T? data, String? message]) {
    return Result(
      success: true,
      data: data,
      message: message,
    );
  }

  factory Result.failure(dynamic error, [String? message]) {
    return Result(
      success: false,
      error: error,
      message: message ?? error.toString(),
    );
  }
}
