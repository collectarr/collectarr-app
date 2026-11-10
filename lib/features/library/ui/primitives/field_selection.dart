import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/generic/folder_reorder_row.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_chrome.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/app_checkbox.dart';
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
      required this.icon,
      required this.accent,
      required this.child,
      required this.onSave,
      this.confirmLabel = 'Save',
      this.headerAction,
      this.onBack});
  final String title;
  final IconData icon;
  final Color accent;
  final Widget child;
  final VoidCallback? onSave;
  final String confirmLabel;
  final Widget? headerAction;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Theme(
      data: Theme.of(context).copyWith(
          // The reference lists have no click ripple.
          highlightColor: Colors.transparent,
          colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: palette.utilityAction, onPrimary: Colors.white),
          extensions: [
            ...Theme.of(context)
                .extensions
                .values
                .where((extension) => extension is! AppThemePalette),
            palette.copyWith(
                accent: palette.utilityAction,
                selection: Color.alphaBlend(
                    palette.utilityAction.withValues(alpha: .22),
                    palette.panel))
          ]),
      child: Builder(
          builder: (context) => appPresentationPlatform.isNativeMobile
              ? MobilePage(
                  title: title,
                  headerColor: accent,
                  backgroundColor: pickListSurface(context),
                  onBack: onBack ?? () => Navigator.of(context).pop(),
                  actions: [
                    if (headerAction != null) headerAction!,
                    TextButton(
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.white),
                        onPressed: onSave,
                        child: Text(confirmLabel)),
                  ],
                  body:
                      Padding(padding: const EdgeInsets.all(12), child: child),
                )
              : Dialog(
                  alignment: Alignment.topCenter,
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                  backgroundColor: pickListSurface(context),
                  shape: appDialogShape,
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
                                minHeight: 38,
                                trailing: headerAction,
                                onClose: () => Navigator.of(context).pop()),
                            Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: child)),
                            DialogActionFooter(actions: [
                              DialogActionButton(
                                  label: 'Cancel',
                                  onPressed: () => Navigator.of(context).pop()),
                              DialogActionButton(
                                  label: confirmLabel,
                                  primary: true,
                                  onPressed: onSave),
                            ]),
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
        if (appPresentationPlatform.isNativeMobile &&
            constraints.maxWidth < 600) {
          return DefaultTabController(
              length: 2,
              child: Column(children: [
                const TabBar(tabs: [
                  Tab(text: 'Fields', height: 48),
                  Tab(text: 'Selected', height: 48)
                ]),
                Expanded(child: TabBarView(children: [available, right])),
              ]));
        }
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

class LibraryFieldSelectionSearch extends StatefulWidget {
  const LibraryFieldSelectionSearch(
      {super.key, this.controller, required this.onChanged});
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;
  @override
  State<LibraryFieldSelectionSearch> createState() =>
      _LibraryFieldSelectionSearchState();
}

class _LibraryFieldSelectionSearchState
    extends State<LibraryFieldSelectionSearch> {
  TextEditingController? _ownedController;

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        widget.controller ?? (_ownedController ??= TextEditingController());
    final palette = appPalette(context);
    final ink = palette.isDark ? Colors.white : palette.textPrimary;
    return SizedBox(
        height: appPresentationPlatform.isNativeMobile ? 48 : 28,
        child: TextField(
            controller: controller,
            style: librarySelectionFieldStyle,
            // The reference types with a white caret.
            cursorColor: palette.utilityAction,
            onChanged: (value) {
              setState(() {});
              widget.onChanged(value);
            },
            decoration: pickListInputDecoration(context).copyWith(
                contentPadding: EdgeInsets.zero,
                prefixIcon: Icon(AppIcons.search, size: 16, color: ink),
                prefixIconConstraints:
                    const BoxConstraints.tightFor(width: 30, height: 26),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : Tooltip(
                        message: 'Clear search',
                        child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  controller.clear();
                                  setState(() {});
                                  widget.onChanged('');
                                },
                                // A filled disc with the cross cut out, as in
                                // the reference.
                                child: Center(
                                    child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                            color: ink, shape: BoxShape.circle),
                                        child: Icon(AppIcons.close,
                                            size: 9,
                                            color: palette.isDark
                                                ? const Color(0xFF444444)
                                                : palette.field)))))),
                suffixIconConstraints:
                    const BoxConstraints.tightFor(width: 26, height: 26))));
  }
}

/// Check state of a whole field group.
enum LibraryFieldCheckState { none, some, all }

/// The reference's 16 px square: a 2 px outline, a white fill with a dark
/// tick when checked, or a dash when only some fields are.
class LibraryFieldCheckbox extends StatelessWidget {
  const LibraryFieldCheckbox({super.key, required this.state});
  final LibraryFieldCheckState state;
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final ink = palette.isDark ? Colors.white : palette.textPrimary;
    final dark = palette.isDark ? const Color(0xFF262626) : palette.panel;
    final some = state == LibraryFieldCheckState.some;
    return AppCheckMark(
        value: switch (state) {
          LibraryFieldCheckState.all => true,
          LibraryFieldCheckState.some => null,
          LibraryFieldCheckState.none => false,
        },
        look: AppCheckLook(
            fill: Colors.transparent,
            // A partial selection keeps the outline and shows an ink dash.
            checkedFill: some ? Colors.transparent : ink,
            check: some ? ink : dark,
            border: ink,
            checkedBorder: ink,
            borderWidth: 2));
  }
}

class LibraryFieldSelectionCategory extends StatefulWidget {
  const LibraryFieldSelectionCategory(
      {super.key,
      required this.title,
      required this.expanded,
      required this.onToggle,
      required this.children,
      this.check,
      this.onToggleAll});
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  /// Group checkbox state; null shows no checkbox.
  final LibraryFieldCheckState? check;
  final VoidCallback? onToggleAll;
  @override
  State<LibraryFieldSelectionCategory> createState() =>
      _LibraryFieldSelectionCategoryState();
}

class _LibraryFieldSelectionCategoryState
    extends State<LibraryFieldSelectionCategory>
    with SingleTickerProviderStateMixin {
  // Bootstrap's collapse: height over 350 ms with the default ease.
  late final AnimationController _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: widget.expanded ? 1 : 0);
  late final Animation<double> _height =
      CurvedAnimation(parent: _controller, curve: Curves.ease);

  @override
  void didUpdateWidget(LibraryFieldSelectionCategory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded == oldWidget.expanded) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = widget.expanded ? 1 : 0;
    } else {
      widget.expanded ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final check = widget.check;
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                  color: pickListToolbar(context),
                  borderRadius: BorderRadius.circular(4),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                      onTap: widget.onToggle,
                      child: SizedBox(
                          height:
                              appPresentationPlatform.isNativeMobile ? 48 : 28,
                          child: Row(children: [
                            if (check != null)
                              GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: widget.onToggleAll,
                                  child: SizedBox(
                                      width: 28,
                                      child: Center(
                                          child: LibraryFieldCheckbox(
                                              state: check))))
                            else
                              const SizedBox(width: 8),
                            Expanded(
                                child: Text(widget.title,
                                    style: librarySelectionFieldStyle)),
                            SizedBox(
                                width: 28,
                                child: AnimatedRotation(
                                    turns: widget.expanded ? 0 : 0.5,
                                    duration: const Duration(milliseconds: 100),
                                    curve: Curves.linear,
                                    child: const Icon(AppIcons.chevronUp,
                                        size: 14))),
                          ])))),
              const SizedBox(height: 1),
              AnimatedBuilder(
                  animation: _height,
                  builder: (context, child) => _controller.isDismissed
                      ? const SizedBox.shrink()
                      : ClipRect(
                          child: Align(
                              alignment: Alignment.topCenter,
                              heightFactor: _height.value,
                              child: child)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.children)),
            ]));
  }
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
      height: appPresentationPlatform.isNativeMobile ? 48 : 28,
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
                    LibraryFieldCheckbox(
                        state: selected
                            ? LibraryFieldCheckState.all
                            : LibraryFieldCheckState.none),
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
      this.ascending,
      this.onToggleDirection,
      this.handleKey});
  final String label;
  final VoidCallback? onRemove;
  final String removeTooltip;

  /// Sort direction shown by the ASC/DESC switch; null hides the switch.
  final bool? ascending;
  final VoidCallback? onToggleDirection;
  final Key? handleKey;
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final color = palette.isDark ? const Color(0xff444444) : palette.field;
    return LibraryFolderReorderRow(
        selectedField: true,
        height: appPresentationPlatform.isNativeMobile ? 48 : 28,
        bottomSpacing: 3,
        color: color,
        hoverColor: color,
        borderColor: palette.isDark ? const Color(0xff666666) : palette.divider,
        child: Row(children: [
          SizedBox(
              width: 26, child: Icon(AppIcons.menu, key: handleKey, size: 16)),
          Expanded(
              child: Text(label,
                  style: librarySelectionFieldStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
          if (ascending case final ascending?)
            _SortDirectionSwitch(
                ascending: ascending, onTap: onToggleDirection),
          Tooltip(
              message: removeTooltip,
              child: MouseRegion(
                  cursor: onRemove == null
                      ? MouseCursor.defer
                      : SystemMouseCursors.click,
                  child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onRemove,
                      child: SizedBox(
                          width:
                              appPresentationPlatform.isNativeMobile ? 48 : 25,
                          height:
                              appPresentationPlatform.isNativeMobile ? 48 : 26,
                          child: Center(
                              child: Icon(AppIcons.close,
                                  size: 12,
                                  color: onRemove == null
                                      ? palette.textMuted
                                      : palette.textPrimary)))))),
        ]));
  }
}

/// The reference's ASC/DESC switch: a 41 x 20 window over two 12 px labels
/// that slides 200 ms linear between them.
class _SortDirectionSwitch extends StatelessWidget {
  const _SortDirectionSwitch({required this.ascending, required this.onTap});
  final bool ascending;
  final VoidCallback? onTap;
  static const _width = 41.0;
  static const _height = 20.0;

  Widget _label(String text, Color color, Color fill, Color border) =>
      Container(
          width: _width,
          height: _height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: border)),
          child: Text(text,
              style: TextStyle(
                  fontFamily: appFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 18 / 12,
                  color: color)));

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    if (appPresentationPlatform.isNativeMobile) {
      return IconButton(
          tooltip: ascending ? 'Sort descending' : 'Sort ascending',
          onPressed: onTap,
          icon: Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward));
    }
    final ink = palette.isDark ? Colors.white : palette.textPrimary;
    final dark = palette.isDark ? const Color(0xFF1D1D1D) : palette.panel;
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: SizedBox(
                width: _width,
                height: _height,
                child: ClipRect(
                    child: Stack(children: [
                  AnimatedPositioned(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 200),
                      curve: Curves.linear,
                      left: ascending ? -_width : 0,
                      top: 0,
                      width: _width * 2,
                      height: _height,
                      child: Row(children: [
                        _label('DESC', ink, Colors.transparent, ink),
                        _label('ASC', dark, ink, ink),
                      ])),
                ])))));
  }
}
