import 'dart:async';

import 'package:collectarr_app/features/library/actions/import_export_actions.dart';
import '../contract_test_helpers.dart';

void defineExportActionContract<TAction, TContext>({
  required String name,
  required TAction Function() create,
  required FutureOr<ExportArtifact> Function(
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
