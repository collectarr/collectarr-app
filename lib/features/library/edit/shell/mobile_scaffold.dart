import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';

/// Native editor chrome around the shared form, tabs and guarded commands.
class LibraryMobileEditorScaffold extends StatelessWidget {
  const LibraryMobileEditorScaffold({
    super.key,
    required this.title,
    required this.accent,
    required this.onBack,
    required this.onSave,
    required this.body,
    this.isBusy = false,
    this.onPropose,
    this.onPrevious,
    this.onNext,
    this.primaryAction,
    this.tabs,
    this.footer,
  });

  final String title;
  final Color accent;
  final VoidCallback onBack;
  final VoidCallback? onSave;
  final VoidCallback? onPropose;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool isBusy;
  final Widget? primaryAction;
  final Widget? tabs;
  final Widget? footer;
  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
        key: const Key('library.mobile-editor'),
        resizeToAvoidBottomInset: true,
        backgroundColor: appPalette(context).surfaceBright,
        appBar: AppBar(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back),
              onPressed: isBusy ? null : onBack),
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            if (primaryAction != null)
              primaryAction!
            else
              TextButton(
                key: const Key('library.mobile-editor.save'),
                onPressed: isBusy ? null : onSave,
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size(64, 48)),
                child: Text(isBusy ? 'Saving…' : 'Save'),
              ),
            if (onPropose != null || onPrevious != null || onNext != null)
              PopupMenuButton<VoidCallback>(
                tooltip: 'More editor actions',
                enabled: !isBusy,
                onSelected: (action) => action(),
                itemBuilder: (_) => [
                  if (onPropose != null)
                    PopupMenuItem(
                        value: onPropose, child: const Text('Propose to Core')),
                  if (onPrevious != null)
                    PopupMenuItem(
                        value: onPrevious, child: const Text('Previous item')),
                  if (onNext != null)
                    PopupMenuItem(
                        value: onNext, child: const Text('Next item')),
                ],
              ),
          ],
        ),
        body: SafeArea(
            top: false,
            child: Column(children: [
              if (tabs != null) tabs!,
              Expanded(child: body),
              if (footer != null &&
                  MediaQuery.viewInsetsOf(context).bottom == 0)
                Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                    child: footer!),
            ])),
      );
}
