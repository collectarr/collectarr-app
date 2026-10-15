import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';

/// One shell for selection and management, so changing modes keeps its position.
class PickListDialog extends StatelessWidget {
  const PickListDialog({super.key, required this.child, this.alignment});
  final Widget child;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final currentDepth = ModalDialogDepthScope.of(context);
    final resolvedAlignment = alignment ?? Alignment.center;

    return ModalDialogDepthScope(
      depth: currentDepth + 1,
      parentAlignment: resolvedAlignment,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        alignment: resolvedAlignment,
        backgroundColor: pickListSurface(context),
        shape: appDialogShape,
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 720,
            maxHeight: MediaQuery.sizeOf(context).height - 48,
          ),
          child: child,
        ),
      ),
    );
  }
}

class PickListHeader extends StatelessWidget {
  const PickListHeader(
      {super.key,
      required this.title,
      this.icon = AppIcons.pickLists,
      this.onClose});
  final String title;
  final IconData icon;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => AccentDialogHeader(
      icon: icon, minHeight: 38, title: title, onClose: onClose);
}

ButtonStyle pickListButtonStyle(BuildContext context,
    {bool primary = true, bool footer = false}) {
  if (footer) return dialogActionButtonStyle(context, primary: primary);
  final palette = appPalette(context);
  return FilledButton.styleFrom(
      backgroundColor:
          primary ? palette.utilityAction : pickListToolbar(context),
      foregroundColor: primary ? Colors.white : palette.textPrimary,
      minimumSize: const Size(0, 32),
      maximumSize: const Size(double.infinity, 32),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      textStyle: TextStyle(
          fontFamily: appFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: BorderSide.none,
      visualDensity: VisualDensity.standard,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap);
}

/// The reference toolbar has three groups, rather than spacing each button.
class PickListToolbar extends StatelessWidget {
  const PickListToolbar(
      {super.key, required this.search, this.middle, this.trailing});
  final Widget search;
  final Widget? middle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
      color: pickListToolbar(context),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      child: LayoutBuilder(builder: (context, constraints) {
        final searchField = SizedBox(
            width: constraints.maxWidth < 200 ? constraints.maxWidth : 200,
            height: 32,
            child: search);
        if (constraints.maxWidth < 620) {
          return Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                searchField,
                if (middle != null) middle!,
                if (trailing != null) trailing!
              ]);
        }
        return Row(children: [
          searchField,
          Expanded(child: Center(child: middle)),
          if (trailing != null) trailing!,
        ]);
      }));
}

class PickListCount extends StatelessWidget {
  const PickListCount({super.key, required this.count, required this.label});
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
          color: const Color(0xffcccccc),
          borderRadius: BorderRadius.circular(4)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xff333333),
                borderRadius: BorderRadius.circular(4)),
            child: Text('$count',
                style: const TextStyle(fontSize: 12, color: Colors.white))),
        const SizedBox(width: 5),
        Flexible(
            child: Text(label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 12, color: Color(0xff444444)))),
      ]));
}

Color pickListSurface(BuildContext context) => appPalette(context).isDark
    ? const Color(0xff262626)
    : appPalette(context).panel;
Color pickListDivider(BuildContext context) => appPalette(context).isDark
    ? const Color(0xff383838)
    : appPalette(context).divider;
Color pickListToolbar(BuildContext context) => appPalette(context).isDark
    ? const Color(0xff464950)
    : appPalette(context).panelRaised;
Color pickListRow(BuildContext context, int index) => appPalette(context).isDark
    ? index.isEven
        ? const Color(0xff262626)
        : const Color(0xff2b2b2b)
    : index.isEven
        ? appPalette(context).tableEvenRow
        : appPalette(context).tableOddRow;

InputDecoration pickListInputDecoration(BuildContext context,
    {String? hintText, Widget? suffixIcon}) {
  final palette = appPalette(context);
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(
          color: palette.isDark ? const Color(0xff666666) : palette.divider));
  return InputDecoration(
      hintText: hintText,
      isDense: true,
      filled: true,
      fillColor: palette.isDark ? const Color(0xff444444) : palette.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
          borderSide: BorderSide(color: palette.utilityAction, width: 2)),
      suffixIconConstraints:
          const BoxConstraints.tightFor(width: 30, height: 30),
      suffixIcon: suffixIcon);
}
