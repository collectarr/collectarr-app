import 'package:flutter/material.dart';

class MusicDiscTabButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final label =
        (title?.trim().isNotEmpty == true) ? title!.trim() : 'Disc #$number';
    return InkWell(
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
          color: selected ? const Color(0xFF383838) : const Color(0xFF131313),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          border: Border(
            top: BorderSide(
              color:
                  selected ? const Color(0xFF555555) : const Color(0xFF262626),
            ),
            left: BorderSide(
              color:
                  selected ? const Color(0xFF555555) : const Color(0xFF262626),
            ),
            right: BorderSide(
              color:
                  selected ? const Color(0xFF555555) : const Color(0xFF262626),
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
                color: selected ? Colors.white : const Color(0xFFAAAAAA),
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: onRemove,
                mouseCursor: SystemMouseCursors.click,
                borderRadius: BorderRadius.circular(2),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 13,
                    color: Color(0xFFCC3333),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
