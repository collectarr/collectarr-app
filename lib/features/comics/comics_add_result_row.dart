import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:flutter/material.dart';

class AddResultRow extends StatefulWidget {
  const AddResultRow({
    super.key,
    required this.selected,
    required this.checked,
    required this.checkDisabled,
    required this.cover,
    required this.title,
    required this.subtitle,
    required this.badges,
    required this.trailing,
    required this.onTap,
    required this.onToggleCheck,
  });

  final bool selected;
  final bool checked;
  final bool checkDisabled;
  final Widget cover;
  final String title;
  final String subtitle;
  final List<String> badges;
  final String trailing;
  final VoidCallback onTap;
  final VoidCallback? onToggleCheck;

  @override
  State<AddResultRow> createState() => _AddResultRowState();
}

class _AddResultRowState extends State<AddResultRow> {
  var _flashSelection = false;

  @override
  void didUpdateWidget(covariant AddResultRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.selected && widget.selected) {
      setState(() => _flashSelection = true);
      Future<void>.delayed(const Duration(milliseconds: 520), () {
        if (mounted) {
          setState(() => _flashSelection = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final subtitle = widget.subtitle.trim();
    final highlightColor = _flashSelection
        ? kClzYellow.withValues(alpha: 0.22)
        : selected
            ? kClzSelection
            : const Color(0xFF242729);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: highlightColor,
        border: Border(
          left: BorderSide(
            color: selected ? kClzYellow : Colors.transparent,
            width: selected ? 4 : 3,
          ),
          bottom: const BorderSide(color: Color(0xFF36393B)),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: kClzAccent.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            child: Row(
              children: [
                Checkbox(
                  value: widget.checked,
                  onChanged: widget.checkDisabled
                      ? null
                      : (_) => widget.onToggleCheck?.call(),
                  visualDensity: VisualDensity.compact,
                ),
                widget.cover,
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFDDDDDD),
                          ),
                        ),
                      ],
                      if (widget.badges.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (final badge in widget.badges)
                              LibraryAddResultBadge(badge),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.trailing.isNotEmpty)
                  Text(
                    widget.trailing,
                    style: const TextStyle(color: Color(0xFFBFEFFF)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
