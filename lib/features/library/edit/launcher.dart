import 'package:collectarr_app/features/library/edit/session/commit_scope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/features/library/entries/store.dart';
import 'package:collectarr_app/features/library/edit/draft/entry_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/features/library/edit/shell/dialog.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:collectarr_app/ui/accent_alert_dialog.dart';

import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/ui/app_dialog.dart';

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
  final database = ProviderScope.containerOf(context, listen: false)
      .read(localDatabaseProvider);

  Future<LibraryEntryEditDraft?> loadDraft(
      LibraryEditDialogRequest request) async {
    final entryRef =
        request.target?.libraryEntryRef ?? request.kindItem.libraryEntryRef;
    if (entryRef == null) return null;
    final key = entryRef.key;
    if (sessions.containsKey(key)) return sessions[key];
    final entry = await LibraryEntryStore(database)
        .find(entryRef.kind, entryRef.id.value);
    if (entry == null) return null;
    final draft = LibraryEntryEditDraft(entry);
    sessions[key] = draft;
    return draft;
  }

  LibraryEditDialogBuilder builderForRequest(
    LibraryEditDialogRequest currentRequest, {
    ({LibraryEntryEditDraft? draft})? preloaded,
  }) {
    final currentCapability =
        libraryEditPresentationForKind(currentRequest.type.kind);
    final currentBuilder = currentCapability.editRegistry.builderForTarget(
      currentRequest.target,
    );
    return (ctx, nextRequest) => _LibraryEntryEditorFrame(
          request: nextRequest,
          builder: currentBuilder,
          onCommit: onCommit,
          preloaded: preloaded,
          load: () => loadDraft(nextRequest),
        );
  }

  // A save that keeps the dialog open leaves the cached drafts stale.
  final commits = LibraryEditCommitHandle(
    itemLabel: request.type.identity.singularLabel.toLowerCase(),
    onKeptOpen: sessions.clear,
  );
  Widget widgetBuilder(BuildContext ctx) {
    if (requestListenable != null) {
      return LibraryEditCommitScope(
        handle: commits,
        child: _SwitchingLibraryEditDialog(
          requestListenable: requestListenable,
          loadDraft: loadDraft,
          builderForRequest: builderForRequest,
          commits: commits,
        ),
      );
    }
    if (requestLoader == null) return builderForRequest(request)(ctx, request);
    return _DeferredLibraryEditDialog(
      initialRequest: request,
      requestLoader: requestLoader,
      builder: (ctx, nextRequest) =>
          builderForRequest(nextRequest)(ctx, nextRequest),
    );
  }

  LibraryEditSelection? result;
  try {
    if (appPresentationPlatform.isNativeMobile) {
      result = await Navigator.of(context, rootNavigator: true)
          .push<LibraryEditSelection>(
        MaterialPageRoute<LibraryEditSelection>(
          fullscreenDialog: true,
          builder: (ctx) => Scaffold(
              resizeToAvoidBottomInset: false, body: widgetBuilder(ctx)),
        ),
      );
    } else {
      result = await showAppDialog<LibraryEditSelection>(
        context: context,
        barrierDismissible: false,
        builder: widgetBuilder,
      );
    }
    if (result == null) return null;
    final entryRef = result.kindItem.libraryEntryRef;
    final draft = entryRef == null ? null : sessions[entryRef.key];
    return draft?.used == true
        ? result.copyWith(entryPersonalData: draft!.changes)
        : result;
  } finally {
    for (final draft in sessions.values) {
      draft.dispose();
    }
  }
}

class _LibraryEntryEditorFrame extends StatefulWidget {
  const _LibraryEntryEditorFrame(
      {required this.request,
      required this.builder,
      required this.load,
      this.preloaded,
      this.onCommit});
  final LibraryEditDialogRequest request;
  final LibraryEditDialogBuilder builder;
  final Future<LibraryEntryEditDraft?> Function() load;

  /// A draft already loaded, so the editor shows at once with no spinner.
  final ({LibraryEntryEditDraft? draft})? preloaded;
  final Future<void> Function(LibraryEditSelection result)? onCommit;
  @override
  State<_LibraryEntryEditorFrame> createState() =>
      _LibraryEntryEditorFrameState();
}

class _LibraryEntryEditorFrameState extends State<_LibraryEntryEditorFrame> {
  late final Future<LibraryEntryEditDraft?> _draft =
      widget.preloaded == null ? widget.load() : Future.value(null);
  @override
  Widget build(BuildContext context) {
    final preloaded = widget.preloaded;
    if (preloaded != null) return _scoped(preloaded.draft);
    return FutureBuilder<LibraryEntryEditDraft?>(
      future: _draft,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return AccentAlertDialog(
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
        return _scoped(snapshot.data);
      },
    );
  }

  Widget _scoped(LibraryEntryEditDraft? draft) => LibraryEntryEditScope(
      draft: draft,
      onCommit: widget.onCommit,
      child: Builder(builder: (ctx) => widget.builder(ctx, widget.request)));
}

class _SwitchingLibraryEditDialog extends StatefulWidget {
  const _SwitchingLibraryEditDialog({
    required this.requestListenable,
    required this.loadDraft,
    required this.builderForRequest,
    required this.commits,
  });

  final ValueListenable<LibraryEditDialogRequest> requestListenable;
  final LibraryEditCommitHandle commits;
  final Future<LibraryEntryEditDraft?> Function(
      LibraryEditDialogRequest request) loadDraft;
  final LibraryEditDialogBuilder Function(
    LibraryEditDialogRequest request, {
    ({LibraryEntryEditDraft? draft})? preloaded,
  }) builderForRequest;

  @override
  State<_SwitchingLibraryEditDialog> createState() =>
      _SwitchingLibraryEditDialogState();
}

class _SwitchingLibraryEditDialogState
    extends State<_SwitchingLibraryEditDialog> {
  late LibraryEditDialogRequest _request;
  ({LibraryEntryEditDraft? draft})? _preloaded;
  int _switches = 0;

  @override
  void initState() {
    super.initState();
    _request = widget.requestListenable.value;
    widget.requestListenable.addListener(_onRequestChanged);
  }

  void _onRequestChanged() =>
      widget.commits.pendingSwitch = _switchToRequested();

  @override
  void didUpdateWidget(covariant _SwitchingLibraryEditDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requestListenable == widget.requestListenable) return;
    oldWidget.requestListenable.removeListener(_onRequestChanged);
    _request = widget.requestListenable.value;
    widget.requestListenable.addListener(_onRequestChanged);
  }

  /// Loads the next item's draft before swapping, so the open dialog is never
  /// replaced by a spinner that lets the page behind show through.
  Future<void> _switchToRequested() async {
    final next = widget.requestListenable.value;
    final switchId = ++_switches;
    final draft = await widget.loadDraft(next);
    if (!mounted || switchId != _switches) return;
    setState(() {
      _request = next;
      _preloaded = (draft: draft);
    });
  }

  @override
  void dispose() {
    widget.requestListenable.removeListener(_onRequestChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: widget.commits.hidden,
        builder: (context, hidden, child) =>
            Offstage(offstage: hidden, child: child),
        child: KeyedSubtree(
          key: ObjectKey(_request),
          child: widget.builderForRequest(_request, preloaded: _preloaded)(
              context, _request),
        ),
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
