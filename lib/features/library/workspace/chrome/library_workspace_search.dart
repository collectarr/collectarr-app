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
    const inputHeight = 34.0;
    final inlineActionCount =
        1 + (onScanBarcode != null ? 1 : 0) + (onScanCover != null ? 1 : 0);
    final inlineActionsWidth = inlineActionCount * 28.0 + 8;
    final inputBackground = colorScheme.brightness == Brightness.dark
      ? Color.alphaBlend(palette.surface.withValues(alpha: 0.34), palette.field)
      : const Color(0xFFF2F4F6);
    final borderColor = colorScheme.brightness == Brightness.dark
      ? const Color(0xFF4F565D)
      : const Color(0xFFD0D7DD);
    return LayoutBuilder(
      builder: (context, constraints) {
        final showFilterChip =
            selectedFilterLabel != null && constraints.maxWidth >= 340;
        final availableWidth = constraints.hasBoundedWidth
            ? (constraints.maxWidth < maxWidth ? constraints.maxWidth : maxWidth)
            : maxWidth;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: availableWidth),
                child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: inputBackground,
                    border: Border.all(color: borderColor),
                  ),
                  child: SizedBox(
                    height: inputHeight,
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      onSubmitted: onSearch,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11.5,
                            height: 1.05,
                          ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: hintText,
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: palette.textMuted,
                              fontSize: 11,
                              height: 1.05,
                            ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: inlineActionsWidth,
                          maxWidth: inlineActionsWidth,
                          minHeight: inputHeight,
                          maxHeight: inputHeight,
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
            ),
            if (showFilterChip) ...[
              const SizedBox(width: 6),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    selectionColor.withValues(alpha: 0.14),
                    palette.surface,
                  ),
                  border: Border.all(
                    color: selectionColor.withValues(alpha: 0.55),
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedFilterLabel!,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (onClearFilter != null) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onClearFilter,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: palette.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
      width: 28,
      child: IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        constraints: const BoxConstraints.tightFor(width: 28, height: 28),
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: palette.textPrimary),
      ),
    );
  }
}