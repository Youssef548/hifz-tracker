class ApiFailure {
  final String code;
  final String message;
  final Object? details;

  const ApiFailure({required this.code, required this.message, this.details});

  static const retryableCodes = {'NETWORK', 'SERVER'};

  bool get isRetryable => retryableCodes.contains(code);
}
