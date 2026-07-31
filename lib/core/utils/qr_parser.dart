import 'package:uuid/uuid.dart';

class QrParser {
  static const String prefix = 'DAIRYTRACE:';

  /// Parses a raw QR code string.
  /// 
  /// Returns the extracted UUID if valid, or null if the string is malformed,
  /// doesn't have the correct prefix, or the UUID is invalid.
  static String? extractToken(String? rawValue) {
    if (rawValue == null) return null;

    final trimmed = rawValue.trim();

    if (!trimmed.startsWith(prefix)) {
      return null;
    }

    final possibleUuid = trimmed.substring(prefix.length).trim();

    // Validate if it's a valid UUID
    if (Uuid.isValidUUID(fromString: possibleUuid)) {
      return possibleUuid;
    }

    return null;
  }
}
