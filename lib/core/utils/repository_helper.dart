import 'package:supabase_flutter/supabase_flutter.dart';
import '../exceptions/repository_exception.dart';

mixin RepositoryHelper {
  /// Safely executes a database call and maps Supabase exceptions to domain exceptions.
  Future<T> executeDb<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        throw AppAuthException(
          'Permission denied. You do not have access to this resource.',
          code: e.code,
          originalError: e,
        );
      }
      throw RepositoryException(
        'Database error: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } on AuthException catch (e) {
      throw AppAuthException(e.message, originalError: e);
    } catch (e) {
      // Handle network, parsing, or unexpected errors
      throw RepositoryException(
        'An unexpected error occurred: $e',
        originalError: e,
      );
    }
  }

  /// Parses a UTC date string to local time safely.
  DateTime parseDateToLocal(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr.toString()).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }
}
