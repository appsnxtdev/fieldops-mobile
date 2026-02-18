import 'package:dio/dio.dart';

/// Returns a short, supervisor-friendly message for any error.
/// Never exposes stack traces, DioException details, or response.body.
String userFacingMessage(Object error, {String? context}) {
  final prefix = context != null && context.isNotEmpty ? '$context failed. ' : '';
  if (error is DioException) {
    final code = error.response?.statusCode;
    if (code == 401) return 'Session expired. Please log in again.';
    if (code == 403) return 'You don\'t have permission to do this.';
    if (code == 404) return 'Not found. It may have been removed.';
    if (code != null && code >= 500) return '${prefix}Server is busy. Please try again in a moment.';
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        (error.type == DioExceptionType.unknown && error.response == null)) {
      return 'No internet. Try again when you\'re back online.';
    }
    return '${prefix}Something went wrong. Please try again.';
  }
  return '${prefix}Something went wrong. Please try again.';
}
