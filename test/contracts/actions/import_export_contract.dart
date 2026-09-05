import 'dart:async';
import 'dart:typed_data';

import '../contract_test_helpers.dart';

final class ExportArtifactContractFixture {
  const ExportArtifactContractFixture({
    required this.filename,
    required this.mimeType,
    required this.bytes,
  });

  final String filename;
  final String mimeType;
  final Uint8List bytes;
}

void defineExportActionContract<TAction, TContext>({
  required String name,
  required TAction Function() create,
  required FutureOr<ExportArtifactContractFixture> Function(
    TAction action,
    TContext context,
  ) export,
  required TContext Function() createContext,
}) {
  defineAsyncTypedContract<TAction>(
    name: '$name export action contract',
    create: create,
    check: (action) async {
      final artifact = await export(action, createContext());
      expectNonEmpty(artifact.filename, '$name export filename is required');
      expectContract(
        !artifact.filename.contains('/') && !artifact.filename.contains(r'\'),
        '$name export filename must be a basename',
      );
      expectNonEmpty(artifact.mimeType, '$name export MIME type is required');
      expectContract(
        artifact.bytes.isNotEmpty,
        '$name export artifact must contain bytes',
      );
    },
  );
}

void defineImportActionContract<TAction, TContext, TPreview>({
  required String name,
  required TAction Function() create,
  required FutureOr<TPreview> Function(TAction action, TContext context)
      preview,
  required Iterable<String> Function(TPreview preview) issues,
  required TContext Function() createContext,
}) {
  defineAsyncTypedContract<TAction>(
    name: '$name import action contract',
    create: create,
    check: (action) async {
      final importPreview = await preview(action, createContext());
      for (final issue in issues(importPreview)) {
        expectNonEmpty(issue, '$name import issues must have messages');
      }
    },
  );
}
