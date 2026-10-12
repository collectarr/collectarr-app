import 'package:collectarr_app/features/library/generic/library_folder_reorder_row.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_chrome.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

TextStyle get librarySelectionFieldStyle => TextStyle(
    fontFamily: appFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1);

/// Shared geometry for columns, sorting and folder field selection.
class LibraryFieldSelectionDialog extends StatelessWidget {
  const LibraryFieldSelectionDialog(
      {super.key,
      required this.title,
      required this.accent,
      required this.child,
      required this.onSave,
      this.confirmLabel = 'Save',
      this.headerAction});
  final String title;
  final Color accent;
  final Widget child;
  final VoidCallback? onSave;
  final String confirmLabel;
  final Widget? headerAction;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Theme(
      data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: accent, onPrimary: appContrastingTextColor(accent)),
          extensions: [
            ...Theme.of(context)
                .extensions
                .values
                .where((extension) => extension is! AppThemePalette),
            palette.copyWith(
                accent: accent,
                selection: Color.alphaBlend(
                    accent.withValues(alpha: .22), palette.panel))
          ]),
      child: Builder(
          builder: (context) => Dialog(
                alignment: Alignment.topCenter,
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                backgroundColor: pickListSurface(context),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                    width: 600,
                    height: MediaQuery.sizeOf(context).height - 60,
                    child: DefaultTextStyle.merge(
                        style: librarySelectionFieldStyle,
                        child: Column(children: [
                          AccentDialogHeader(
                              title: title,
                              accent: accent,
                              flat: true,
                              foregroundColor: Colors.white,
                              minHeight: 38,
                              titleStyle: TextStyle(
                                  fontFamily: appFontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0),
                              trailing: headerAction,
                              onClose: () => Navigator.of(context).pop()),
                          Expanded(
                              child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  child: child)),
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: palette.isDark
                                      ? const Color(0xff383838)
                                      : palette.panelRaised,
                                  border: Border(
                                      top: BorderSide(
                                          color: pickListDivider(context)))),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    FilledButton(
                                        style: pickListButtonStyle(context,
                                            primary: false, footer: true),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Cancel')),
                                    const SizedBox(width: 10),
                                    FilledButton(
                                        style: pickListButtonStyle(context,
                                            footer: true),
                                        onPressed: onSave,
                                        child: Text(confirmLabel)),
                                  ])),
                        ]))),
              )),
    );
  }
}

class LibraryFieldSelectionPanes extends StatelessWidget {
  const LibraryFieldSelectionPanes(
      {super.key, required this.available, required this.selected});
  final Widget available;
  final Widget selected;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final right = DecoratedBox(
            decoration: BoxDecoration(
                color: appPalette(context).isDark
                    ? const Color(0xff1f1f1f)
                    : appPalette(context).surfaceSubtle,
                borderRadius: BorderRadius.circular(4)),
            child: selected);
        if (constraints.maxWidth < 380) {
          return Column(children: [
            Expanded(child: available),
            const SizedBox(height: 10),
            Expanded(child: right)
          ]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(right: 20), child: available)),
          Expanded(child: right)
        ]);
      });
}

class LibraryFieldSelectionSearch extends StatelessWidget {
  const LibraryFieldSelectionSearch(
      {super.key, required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 28,
      child: TextField(
          controller: controller,
          style: librarySelectionFieldStyle,
          cursorColor: LibraryAccentScope.maybeOf(context)?.accent ??
              appPalette(context).accent,
          onChanged: onChanged,
          decoration: pickListInputDecoration(context,
                  hintText: 'Search fields')
              .copyWith(
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: const Icon(Icons.search, size: 16),
                  prefixIconConstraints:
                      const BoxConstraints.tightFor(width: 30, height: 26),
                  suffixIcon: controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.cancel, size: 16),
                          onPressed: () {
                            controller.clear();
                            onChanged('');
                          }),
                  suffixIconConstraints:
                      const BoxConstraints.tightFor(width: 26, height: 26))));
}

class LibraryFieldSelectionCategory extends StatelessWidget {
  const LibraryFieldSelectionCategory(
      {super.key,
      required this.title,
      required this.expanded,
      required this.onToggle,
      required this.children,
      this.selected,
      this.onToggleAll});
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;
  final bool? selected;
  final VoidCallback? onToggleAll;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Material(
            color: pickListToolbar(context),
            borderRadius: BorderRadius.circular(4),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
                onTap: onToggle,
                child: SizedBox(
                    height: 28,
                    child: Row(children: [
                      if (selected != null)
                        SizedBox(
                            width: 28,
                            child: InkWell(
                                onTap: onToggleAll,
                                child: Icon(
                                    selected!
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    size: 16,
                                    color: selected!
                                        ? appPalette(context).accent
                                        : appPalette(context).textMuted)))
                      else
                        const SizedBox(width: 8),
                      Expanded(
                          child:
                              Text(title, style: librarySelectionFieldStyle)),
                      SizedBox(
                          width: 28,
                          child: Icon(
                              expanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 18)),
                    ])))),
        const SizedBox(height: 1),
        if (expanded) ...children,
      ]));
}

class LibraryFieldSelectionCheckbox extends StatelessWidget {
  const LibraryFieldSelectionCheckbox(
      {super.key,
      required this.label,
      required this.selected,
      required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Container(
      height: 28,
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
          border: Border.all(
              color: appPalette(context).isDark
                  ? const Color(0xff666666)
                  : appPalette(context).divider),
          borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
      child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: onTap,
              child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 7),
                  child: Row(children: [
                    Icon(
                        selected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 16,
                        color: selected
                            ? appPalette(context).accent
                            : appPalette(context).textMuted),
                    const SizedBox(width: 5),
                    Expanded(
                        child: Text(label,
                            style: librarySelectionFieldStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                  ])))));
}

class LibrarySelectedFieldRow extends StatelessWidget {
  const LibrarySelectedFieldRow(
      {super.key,
      required this.label,
      required this.onRemove,
      required this.removeTooltip,
      this.direction,
      this.onToggleDirection,
      this.handleKey});
  final String label;
  final VoidCallback? onRemove;
  final String removeTooltip;
  final String? direction;
  final VoidCallback? onToggleDirection;
  final Key? handleKey;
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final color = palette.isDark ? const Color(0xff444444) : palette.field;
    return LibraryFolderReorderRow(
        selectedField: true,
        height: 28,
        bottomSpacing: 3,
        color: color,
        hoverColor: color,
        borderColor: palette.isDark ? const Color(0xff666666) : palette.divider,
        child: Row(children: [
          SizedBox(
              width: 26, child: Icon(Icons.menu, key: handleKey, size: 16)),
          Expanded(
              child: Text(label,
                  style: librarySelectionFieldStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
          if (direction != null)
            SizedBox(
                height: 22,
                child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: palette.textPrimary,
                        foregroundColor: palette.panel,
                        minimumSize: const Size(42, 22),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        textStyle:
                            librarySelectionFieldStyle.copyWith(fontSize: 12),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3))),
                    onPressed: onToggleDirection,
                    child: Text(direction!))),
          IconButton(
              tooltip: removeTooltip,
              onPressed: onRemove,
              style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(28, 26),
                      maximumSize: const Size(28, 26),
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      overlayColor: Colors.transparent,
                      side: BorderSide.none,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap)
                  .copyWith(
                      foregroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.hovered)
                              ? Theme.of(context).colorScheme.error
                              : states.contains(WidgetState.disabled)
                                  ? palette.textMuted
                                  : palette.textPrimary)),
              icon: const Icon(Icons.close, size: 16)),
        ]));
  }
}
