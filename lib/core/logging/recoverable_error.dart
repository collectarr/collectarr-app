import 'dart:developer' as developer;

void logRecoverableError({
  required String source,
  required String message,
  required Object error,
  required StackTrace stackTrace,
}) {
  developer.log(
    message,
    name: 'collectarr.$source',
    error: error,
    stackTrace: stackTrace,
  );
}
