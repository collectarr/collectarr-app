import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

/// Structural duplicate candidate supplied by a kind-owned presentation.
///
/// The generic duplicate host groups candidates and renders their result. It
/// does not know whether a kind produced a barcode, issue, ISBN, platform, or
/// another domain-specific identity.
final class LibraryDuplicateCandidate {
  const LibraryDuplicateCandidate({
    required this.key,
    required this.label,
    required this.reason,
    required this.confidenceScore,
    this.entryLabel,
  });

  final String key;
  final String label;
  final String reason;
  final int confidenceScore;
  final String? entryLabel;
}

String? normalizeLibraryDuplicateToken(Object? value) {
  final normalized = value?.toString().trim();
  return normalized == null || normalized.isEmpty
      ? null
      : normalized.toLowerCase();
}

String? normalizeLibraryDuplicateIdentifier(Object? value) {
  final normalized = value?.toString().replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
  return normalized == null || normalized.isEmpty
      ? null
      : normalized.toLowerCase();
}

typedef LibraryDuplicateCandidateBuilder = List<LibraryDuplicateCandidate>
    Function(LibraryWorkspaceSource entry);
