import 'package:collectarr_app/ui/app_bottom_sheet.dart';
import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';

/// Native editor chrome around the shared form, tabs and guarded commands.
class LibraryMobileEditorScaffold extends StatefulWidget {
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
  State<LibraryMobileEditorScaffold> createState() =>
      _LibraryMobileEditorScaffoldState();
}

class _LibraryMobileEditorScaffoldState
    extends State<LibraryMobileEditorScaffold> {
  late final _collectionContent = ValueNotifier<Widget?>(widget.footer);

  @override
  void didUpdateWidget(LibraryMobileEditorScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The sheet is on another route; update its presentation after the parent
    // frame, while draft values and commands remain owned by the editor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _collectionContent.value = widget.footer;
    });
  }

  @override
  void dispose() {
    _collectionContent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LibraryMobileEditorScaffold(
      :title,
      :accent,
      :onBack,
      :onSave,
      :onPropose,
      :onPrevious,
      :onNext,
      :isBusy,
      :primaryAction,
      :tabs,
      :footer,
      :body
    ) = widget;
    return MobilePage(
      key: const Key('library.mobile-editor'),
      title: title,
      headerColor: accent,
      backgroundColor: appPalette(context).surfaceBright,
      onBack: onBack,
      canGoBack: !isBusy,
      actions: [
        if (footer != null)
          IconButton(
              tooltip: 'Collection details',
              icon: const Icon(Icons.inventory_2_outlined),
              onPressed: isBusy ? null : () => _showCollectionDetails(context)),
        if (primaryAction != null)
          primaryAction
        else
          TextButton(
            key: const Key('library.mobile-editor.save'),
            onPressed: isBusy ? null : onSave,
            style: TextButton.styleFrom(
                foregroundColor: Colors.white, minimumSize: const Size(64, 48)),
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
                PopupMenuItem(value: onNext, child: const Text('Next item')),
            ],
          ),
      ],
      contextBar: tabs,
      body: body,
    );
  }

  void _showCollectionDetails(BuildContext context) {
    FocusScope.of(context).unfocus();
    showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Collection details',
                              style:
                                  Theme.of(sheetContext).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<Widget?>(
                              valueListenable: _collectionContent,
                              builder: (context, content, child) =>
                                  content ?? const SizedBox.shrink()),
                          const SizedBox(height: 16),
                          FilledButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              child: const Text('Done')),
                        ]))),
          )),
    );
  }
}
