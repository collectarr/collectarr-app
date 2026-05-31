import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:flutter/material.dart';

typedef LibraryEditDialogRequestLoader = Future<LibraryEditDialogRequest>
    Function();

Future<LibraryEditSelection?> showLibraryEditDialog({
  required BuildContext context,
  required LibraryEditDialogRequest request,
  LibraryEditDialogRequestLoader? requestLoader,
}) {
  final builder = request.type.editDialogBuilder;
  if (builder == null) {
    throw StateError(
      'No edit dialog builder registered for ${request.type.workspace.kind.apiValue}.',
    );
  }
  return showDialog<LibraryEditSelection>(
    context: context,
    builder: (context) => requestLoader == null
        ? builder(context, request)
        : _DeferredLibraryEditDialog(
            initialRequest: request,
            requestLoader: requestLoader,
            builder: builder,
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

class _DeferredLibraryEditDialogState extends State<_DeferredLibraryEditDialog> {
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
          return AlertDialog(
            title: const Text('Could not open editor'),
            content: Text(
              'Failed to load edit data for ${widget.initialRequest.item.title}.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        }
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380, minHeight: 160),
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                    'Opening editor for ${widget.initialRequest.item.title}...',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
