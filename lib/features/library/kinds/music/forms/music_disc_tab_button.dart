import 'package:flutter/material.dart';

class MusicDiscTabButton extends StatefulWidget {
  const MusicDiscTabButton({
    super.key,
    required this.number,
    this.title,
    this.format,
    required this.selected,
    required this.onPressed,
    this.onRemove,
  });

  final int number;
  final String? title;
  final String? format;
  final bool selected;
  final VoidCallback onPressed;
  final VoidCallback? onRemove;

  @override
  State<MusicDiscTabButton> createState() => _MusicDiscTabButtonState();
}

class _MusicDiscTabButtonState extends State<MusicDiscTabButton> {
  bool _hovered = false;
  bool _closeHovered = false;
  bool get selected => widget.selected;
  String? get title => widget.title;
  int get number => widget.number;
  VoidCallback get onPressed => widget.onPressed;
  VoidCallback? get onRemove => widget.onRemove;

  @override
  Widget build(BuildContext context) {
    final label =
        (title?.trim().isNotEmpty == true) ? title!.trim() : 'Disc #$number';
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _closeHovered = false;
      }),
      child: InkWell(
        onTap: onPressed,
        mouseCursor: SystemMouseCursors.click,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 250),
          curve: Curves.ease,
          height: 32,
          padding: const EdgeInsets.only(left: 12, right: 8),
          decoration: BoxDecoration(
            color: selected || _hovered
                ? const Color(0xFF383838)
                : const Color(0xFF131313),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            border: Border(
              top: BorderSide(
                color: selected
                    ? const Color(0xFF555555)
                    : const Color(0xFF262626),
              ),
              left: BorderSide(
                color: selected
                    ? const Color(0xFF555555)
                    : const Color(0xFF262626),
              ),
              right: BorderSide(
                color: selected
                    ? const Color(0xFF555555)
                    : const Color(0xFF262626),
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              if (onRemove != null) ...[
                const SizedBox(width: 8),
                MouseRegion(
                  onEnter: (_) => setState(() => _closeHovered = true),
                  onExit: (_) => setState(() => _closeHovered = false),
                  child: InkWell(
                    key: ValueKey('music-disc-close-$number'),
                    onTap: onRemove,
                    mouseCursor: SystemMouseCursors.click,
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: _closeHovered
                              ? const Color(0xFF535353)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2)),
                      child: Icon(
                        Icons.close,
                        size: 13,
                        color: _closeHovered
                            ? const Color(0xFFFF625C)
                            : const Color(0xFFD43F3A),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
