import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/ui/app_formatted_text.dart';
import 'package:collectarr_app/ui/app_formatted_text_controller.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A multiline field for text shown by [AppFormattedText]: Rich edits it as
/// shown, with format buttons, and Raw edits its HTML.
///
/// The value only changes through an edit, so looking at a description in
/// either mode leaves its HTML as it was. A description with tags Rich cannot
/// show opens in Raw, and Rich says what editing there would remove.
final class LibraryFormattedTextFormControl extends StatefulWidget {
  const LibraryFormattedTextFormControl({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.minLines,
    this.maxLines = 18,
    this.onChanged,
  }) : assert(controller == null || initialValue == null);

  /// Holds the HTML. Text set on it from outside reloads the Rich view.
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final int? minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  State<LibraryFormattedTextFormControl> createState() =>
      _LibraryFormattedTextFormControlState();
}

class _LibraryFormattedTextFormControlState
    extends State<LibraryFormattedTextFormControl> {
  late final TextEditingController _source =
      widget.controller ?? TextEditingController(text: widget.initialValue);
  late final AppFormattedTextController _rich =
      AppFormattedTextController(_source.text);
  late bool _richMode = droppedAppFormattedTextTags(_source.text).isEmpty;
  late int _revision;

  /// The HTML last written from Rich, to tell it from text set from outside.
  String? _written;

  @override
  void initState() {
    super.initState();
    // Read now: read lazily, the first edit would match its own revision.
    _revision = _rich.revision;
    _source.addListener(_sourceChanged);
    _rich.addListener(_richChanged);
  }

  @override
  void dispose() {
    _source.removeListener(_sourceChanged);
    _rich.removeListener(_richChanged);
    if (widget.controller == null) _source.dispose();
    _rich.dispose();
    super.dispose();
  }

  void _richChanged() {
    if (_rich.revision == _revision) return;
    _revision = _rich.revision;
    final html = _rich.source;
    if (html == _source.text) return;
    _written = html;
    _source.text = html;
    widget.onChanged?.call(html);
  }

  void _sourceChanged() {
    if (!_richMode || _source.text == _written) return;
    _rich.load(_source.text);
    _revision = _rich.revision;
  }

  void _setRichMode(bool rich) {
    if (rich == _richMode) return;
    if (rich) {
      _rich.load(_source.text);
      _revision = _rich.revision;
      _written = _source.text;
    }
    setState(() => _richMode = rich);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Part of the field, so pressing a button keeps its focus and caret.
        TextFieldTapRegion(
          child: _Toolbar(
              controller: _rich,
              richMode: _richMode,
              onRichModeChanged: _setRichMode),
        ),
        const SizedBox(height: 4),
        if (_richMode)
          CallbackShortcuts(
            bindings: {
              for (final (key, mark) in const [
                (LogicalKeyboardKey.keyB, AppTextMark.bold),
                (LogicalKeyboardKey.keyI, AppTextMark.italic),
                (LogicalKeyboardKey.keyU, AppTextMark.underline),
              ]) ...{
                SingleActivator(key, control: true): () =>
                    _rich.toggleMark(mark),
                SingleActivator(key, meta: true): () => _rich.toggleMark(mark),
              },
            },
            child: LibraryTextFormControl(
              key: const ValueKey('formatted-text-rich'),
              controller: _rich,
              focusNode: widget.focusNode,
              // Regular weight, as shown outside the editor, so bold stands out.
              style: context.libraryTextTheme.controlText
                  .copyWith(fontWeight: kAppNormalFontWeight),
              keyboardType: TextInputType.multiline,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
            ),
          )
        else
          LibraryTextFormControl(
            key: const ValueKey('formatted-text-raw'),
            controller: _source,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.multiline,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
          ),
        if (_richMode)
          ListenableBuilder(
            listenable: _source,
            builder: (context, _) {
              final dropped = droppedAppFormattedTextTags(_source.text);
              if (dropped.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Editing here removes tags this view cannot show: '
                  '${dropped.join(', ')}. Raw keeps them.',
                  style: TextStyle(
                      fontSize: 12, color: appPalette(context).textMuted),
                ),
              );
            },
          ),
      ],
    );
  }
}

final class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.richMode,
    required this.onRichModeChanged,
  });

  final AppFormattedTextController controller;
  final bool richMode;
  final ValueChanged<bool> onRichModeChanged;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) => Row(children: [
          if (richMode) ...[
            for (final (mark, label, icon) in const [
              (AppTextMark.bold, 'Bold', AppIcons.formatBold),
              (AppTextMark.italic, 'Italic', AppIcons.formatItalic),
              (AppTextMark.underline, 'Underline', AppIcons.formatUnderline),
            ])
              _ToolbarButton(
                label: label,
                selected: controller.hasMark(mark),
                onPressed: () => controller.toggleMark(mark),
                child: Icon(icon, size: 13),
              ),
            const SizedBox(width: 8),
            for (final (list, label, icon) in const [
              (AppTextList.bullet, 'Bulleted list', AppIcons.formatBulletList),
              (
                AppTextList.numbered,
                'Numbered list',
                AppIcons.formatNumberedList
              ),
            ])
              _ToolbarButton(
                label: label,
                selected: controller.hasList(list),
                onPressed: () => controller.toggleList(list),
                child: Icon(icon, size: 13),
              ),
          ],
          const Spacer(),
          for (final (rich, label) in const [(true, 'Rich'), (false, 'Raw')])
            _ToolbarButton(
              label: label,
              selected: richMode == rich,
              width: 44,
              onPressed: () => onRichModeChanged(rich),
              child: Text(label, style: const TextStyle(fontSize: 12)),
            ),
        ]),
      );
}

final class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    required this.child,
    this.width = 26,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final foreground = selected ? Colors.white : palette.textSecondary;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Material(
            color: selected ? palette.utilityAction : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              canRequestFocus: false,
              mouseCursor: SystemMouseCursors.click,
              onTap: onPressed,
              child: SizedBox(
                width: width,
                height: 24,
                child: Center(
                  child: IconTheme.merge(
                    data: IconThemeData(color: foreground),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: foreground),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
