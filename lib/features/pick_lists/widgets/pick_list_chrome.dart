import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_typography.dart';

/// One shell for selection and management, so changing modes keeps its position.
class PickListDialog extends StatelessWidget {
  const PickListDialog({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Dialog(
      insetPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      alignment: Alignment.topCenter,
      backgroundColor: pickListSurface(context),
      shape: const RoundedRectangleBorder(),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: 720, maxHeight: MediaQuery.sizeOf(context).height - 24),
          child: child));
}

class PickListHeader extends StatelessWidget {
  const PickListHeader({super.key, required this.title, this.onClose});
  final String title;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => AccentDialogHeader(
      minHeight: 38,
      title: title,
      titleStyle: const TextStyle(
          fontFamily: kAppFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700),
      trailing: IconButton(
          tooltip: 'Close',
          onPressed: onClose,
          style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              side: BorderSide.none,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.zero,
              minimumSize: const Size(24, 24),
              maximumSize: const Size(24, 24),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          icon: const Icon(Icons.close, size: 20)));
}

ButtonStyle pickListButtonStyle(BuildContext context,
    {bool primary = true, bool footer = false}) {
  final palette = appPalette(context);
  return FilledButton.styleFrom(
      backgroundColor: primary ? palette.accent : pickListToolbar(context),
      foregroundColor: primary
          ? Theme.of(context).colorScheme.onPrimary
          : palette.textPrimary,
      minimumSize: Size(footer ? 100 : 0, 32),
      maximumSize: const Size(double.infinity, 32),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      textStyle: const TextStyle(
          fontFamily: kAppFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600),
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
          borderSide: BorderSide(color: palette.accent, width: 2)),
      suffixIconConstraints:
          const BoxConstraints.tightFor(width: 30, height: 30),
      suffixIcon: suffixIcon);
}
