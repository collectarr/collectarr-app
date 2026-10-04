import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:collectarr_app/ui/accent_alert_dialog.dart';

import 'package:collectarr_app/ui/adaptive/window_class.dart';

typedef LibraryEditDialogRequestLoader = Future<LibraryEditDialogRequest>
    Function();

Future<LibraryEditSelection?> showLibraryEditDialog({
  required BuildContext context,
  required LibraryEditDialogRequest request,
  LibraryEditDialogRequestLoader? requestLoader,
  ValueListenable<LibraryEditDialogRequest>? requestListenable,
  Future<void> Function(LibraryEditSelection result)? onCommit,
}) async {
  final sessions = <String, LibraryEntryEditDraft>{};
  final database = ProviderScope.containerOf(context, listen: false).read(localDatabaseProvider);
  final editCapability = libraryEditPresentationForKind(request.type.kind);
  final builder = editCapability.editRegistry.builderForScope(
    request.resolvedScope,
  );
  if (builder == null) {
    throw StateError(
      'No edit dialog builder registered for ${request.type.kind.apiValue}.',
    );
  }

  LibraryEditDialogBuilder builderForRequest(
    LibraryEditDialogRequest currentRequest,
  ) {
    final currentCapability =
        libraryEditPresentationForKind(currentRequest.type.kind);
    final currentBuilder = currentCapability.editRegistry.builderForScope(
      currentRequest.resolvedScope,
    );
    if (currentBuilder == null) {
      throw StateError(
        'No edit dialog builder registered for '
        '${currentRequest.type.kind.apiValue}.',
      );
    }
    return (ctx, nextRequest) => _LibraryEntryEditorFrame(
      request: nextRequest,
      builder: currentBuilder,
      onCommit: onCommit,
      load: () async {
        final key = nextRequest.kindItem.reference.toCatalogItemRef().key;
        if (sessions.containsKey(key)) return sessions[key];
        final entry = await LibraryEntryStore(database).find(nextRequest.type.kind, nextRequest.kindItem.reference.id);
        if (entry == null) return null;
        final draft = LibraryEntryEditDraft(entry);
        sessions[key] = draft;
        return draft;
      },
    );
  }

  final windowClass = AppWindowClass.of(context);
  Widget widgetBuilder(BuildContext ctx) {
    if (requestListenable != null) {
      return _SwitchingLibraryEditDialog(
        requestListenable: requestListenable,
        builderForRequest: builderForRequest,
      );
    }
    if (requestLoader == null) return builderForRequest(request)(ctx, request);
    return _DeferredLibraryEditDialog(
      initialRequest: request,
      requestLoader: requestLoader,
      builder: (ctx, nextRequest) => builderForRequest(nextRequest)(ctx, nextRequest),
    );
  }

  LibraryEditSelection? result;
  try {
    if (windowClass.isCompact) {
      result = await Navigator.of(context).push<LibraryEditSelection>(
        MaterialPageRoute<LibraryEditSelection>(
          fullscreenDialog: true,
          builder: (ctx) => Scaffold(body: SafeArea(child: widgetBuilder(ctx))),
        ),
      );
    } else {
      result = await showDialog<LibraryEditSelection>(
        context: context, barrierDismissible: false, builder: widgetBuilder,
      );
    }
    if (result == null) return null;
    final draft = sessions[result.kindItem.reference.toCatalogItemRef().key];
    return draft?.used == true
        ? result.copyWith(entryPersonalData: draft!.changes)
        : result;
  } finally {
    for (final draft in sessions.values) { draft.dispose(); }
  }
}

class _LibraryEntryEditorFrame extends StatefulWidget {
  const _LibraryEntryEditorFrame({required this.request, required this.builder, required this.load, this.onCommit});
  final LibraryEditDialogRequest request;
  final LibraryEditDialogBuilder builder;
  final Future<LibraryEntryEditDraft?> Function() load;
  final Future<void> Function(LibraryEditSelection result)? onCommit;
  @override
  State<_LibraryEntryEditorFrame> createState() => _LibraryEntryEditorFrameState();
}

class _LibraryEntryEditorFrameState extends State<_LibraryEntryEditorFrame> {
  late final Future<LibraryEntryEditDraft?> _draft = widget.load();
  @override
  Widget build(BuildContext context) => FutureBuilder<LibraryEntryEditDraft?>(
    future: _draft,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return AlertDialog(
          title: const Text('Could not open entry'),
          content: Text('${snapshot.error}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      }
      return LibraryEntryEditScope(draft: snapshot.data, onCommit: widget.onCommit, child: Builder(builder: (ctx) => widget.builder(ctx, widget.request)));
    },
  );
}

class _SwitchingLibraryEditDialog extends StatefulWidget {
  const _SwitchingLibraryEditDialog({
    required this.requestListenable,
    required this.builderForRequest,
  });

  final ValueListenable<LibraryEditDialogRequest> requestListenable;
  final LibraryEditDialogBuilder Function(
    LibraryEditDialogRequest request,
  ) builderForRequest;

  @override
  State<_SwitchingLibraryEditDialog> createState() =>
      _SwitchingLibraryEditDialogState();
}

class _SwitchingLibraryEditDialogState
    extends State<_SwitchingLibraryEditDialog> {
  late LibraryEditDialogRequest _request;

  @override
  void initState() {
    super.initState();
    _request = widget.requestListenable.value;
    widget.requestListenable.addListener(_onRequestChanged);
  }

  @override
  void didUpdateWidget(covariant _SwitchingLibraryEditDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requestListenable == widget.requestListenable) return;
    oldWidget.requestListenable.removeListener(_onRequestChanged);
    _request = widget.requestListenable.value;
    widget.requestListenable.addListener(_onRequestChanged);
  }

  void _onRequestChanged() {
    if (!mounted) return;
    setState(() => _request = widget.requestListenable.value);
  }

  @override
  void dispose() {
    widget.requestListenable.removeListener(_onRequestChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeyedSubtree(
        key: ObjectKey(_request),
        child: widget.builderForRequest(_request)(context, _request),
      );
}

class _DeferredLibraryEditDialog extends StatefulWidget {
  const _DeferredLibraryEditDialog({
    required this.initialRequest,
    required this.requestLoader,
    required this.builder,
  });

  final LibraryEditDialogRequest initialRequest;
  final LibraryEditDialogRequestLoader requestLoader;
  final LibraryEditDialogBuilder builder;

  @override
  State<_DeferredLibraryEditDialog> createState() =>
      _DeferredLibraryEditDialogState();
}

class _DeferredLibraryEditDialogState
    extends State<_DeferredLibraryEditDialog> {
  late final Future<LibraryEditDialogRequest> _requestFuture;

  @override
  void initState() {
    super.initState();
    _requestFuture = widget.requestLoader();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LibraryEditDialogRequest>(
      future: _requestFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return widget.builder(context, snapshot.data!);
        }
        if (snapshot.hasError) {
          return AccentAlertDialog(
            title: const Text('Could not open editor'),
            content: Text(
              'Failed to load edit data for ${widget.initialRequest.kindItem.summary.primaryLabel}.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        }
        return AccentAlertDialog(
          title: const Text('Opening editor'),
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading edit data for ${widget.initialRequest.kindItem.summary.primaryLabel}...',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
