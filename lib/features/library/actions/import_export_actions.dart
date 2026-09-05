import 'dart:typed_data';

import 'ui_action.dart';

/// A completed file export returned by a kind-owned serializer.
///
/// File picking, saving, and sharing belong to the generic host. The owning
/// kind supplies the filename, MIME type, and serialized bytes.
final class ExportArtifact {
  const ExportArtifact({
    required this.filename,
    required this.mimeType,
    required this.bytes,
  });

  final String filename;
  final String mimeType;
  final Uint8List bytes;
}

enum ImportPreviewStatus {
  ready,
  needsReview,
  invalid,
}

enum ImportIssueSeverity {
  info,
  warning,
  error,
}

/// A structural issue shown by the generic import review host.
final class ImportIssue {
  const ImportIssue({
    required this.message,
    this.severity = ImportIssueSeverity.info,
  });

  final String message;
  final ImportIssueSeverity severity;
}

/// Structural import review data.
///
/// Parsed rows and matching decisions remain in the concrete [TPreview]
/// owned by a kind. This summary contains only what generic review UI needs.
final class ImportPreview {
  const ImportPreview({
    this.status = ImportPreviewStatus.ready,
    this.issues = const <ImportIssue>[],
    this.conflicts = const <String>[],
  });

  final ImportPreviewStatus status;
  final List<ImportIssue> issues;
  final List<String> conflicts;
}

/// Structural export action contract for a concrete kind.
abstract interface class ExportAction<TContext> implements UiAction<TContext> {
  Future<ExportArtifact> export(TContext context);
}

/// Structural import action contract for a concrete kind.
abstract interface class ImportAction<TContext, TPreview>
    implements UiAction<TContext> {
  Future<TPreview> previewImport(TContext context);

  Future<void> applyImport(TContext context, TPreview preview);
}
