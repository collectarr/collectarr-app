import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryToolbarSearch extends StatelessWidget {
  const LibraryToolbarSearch({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSearch,
    required this.selectionColor,
    this.onScanBarcode,
    this.onScanCover,
    this.selectedFilterLabel,
    this.onClearFilter,
    this.onChanged,
    this.maxWidth = 300,
  });

  final TextEditingController controller;
  final String hintText;
  final String? selectedFilterLabel;
  final ValueChanged<String> onSearch;
  final VoidCallback? onScanBarcode;
  final VoidCallback? onScanCover;
  final VoidCallback? onClearFilter;
  final ValueChanged<String>? onChanged;
  final Color selectionColor;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final colorScheme = Theme.of(context).colorScheme;
    final inlineActionCount =
        1 + (onScanBarcode != null ? 1 : 0) + (onScanCover != null ? 1 : 0);
    final inlineActionsWidth = inlineActionCount * 30.0 + 8;
    final inputBackground = colorScheme.brightness == Brightness.dark
        ? const Color(0xFF34383D)
        : const Color(0xFFF4F6F8);
    final borderColor = colorScheme.brightness == Brightness.dark
        ? const Color(0xFF575D65)
        : const Color(0xFFD6DCE3);
    return LayoutBuilder(
      builder: (context, constraints) {
        final showFilterChip =
            selectedFilterLabel != null && constraints.maxWidth >= 340;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: inputBackground,
                    border: Border.all(color: borderColor),
                  ),
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      onSubmitted: onSearch,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: hintText,
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: palette.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: inlineActionsWidth,
                          maxWidth: inlineActionsWidth,
                          minHeight: 38,
                          maxHeight: 38,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ToolbarSearchInlineAction(
                                tooltip: 'Search',
                                icon: Icons.search,
                                onPressed: () => onSearch(controller.text),
                              ),
                              if (onScanBarcode != null)
                                _ToolbarSearchInlineAction(
                                  tooltip: 'Scan barcode',
                                  icon: Icons.qr_code_2,
                                  onPressed: onScanBarcode!,
                                ),
                              if (onScanCover != null)
                                _ToolbarSearchInlineAction(
                                  tooltip: 'Search by cover',
                                  icon: Icons.image_search,
                                  onPressed: onScanCover!,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (showFilterChip) ...[
              const SizedBox(width: 6),
              InputChip(
                visualDensity: VisualDensity.compact,
                backgroundColor: selectionColor,
                label: Text(selectedFilterLabel!),
                onDeleted: onClearFilter,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ToolbarSearchInlineAction extends StatelessWidget {
  const _ToolbarSearchInlineAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return SizedBox(
      width: 30,
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
          onPressed: onPressed,
          icon: Icon(icon, size: 19, color: palette.textPrimary),
        ),
      ),
    );
  }
}