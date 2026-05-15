import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

class ComicsTopBar extends StatelessWidget {
  const ComicsTopBar({
    super.key,
    required this.totalCount,
    this.onOpenLibraries,
  });

  final int totalCount;
  final VoidCallback? onOpenLibraries;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: const BoxDecoration(
        color: kClzTopBar,
        border: Border(bottom: BorderSide(color: Color(0xFF1B6F80))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          if (onOpenLibraries == null) ...[
            const Icon(Icons.cloud_queue, size: 20, color: Colors.white),
            const SizedBox(width: 8),
          ] else ...[
            _ComicsTopBarButton(
              tooltip: 'All libraries',
              icon: Icons.apps_outlined,
              label: 'Libraries',
              onPressed: onOpenLibraries,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: Colors.white70),
            const SizedBox(width: 8),
          ],
          const Text(
            'Comics',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          Text(
            '$totalCount local comics',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.grid_view, size: 18, color: Colors.white),
          const SizedBox(width: 10),
          const Icon(Icons.person, size: 18, color: Colors.white),
        ],
      ),
    );
  }
}

class _ComicsTopBarButton extends StatelessWidget {
  const _ComicsTopBarButton({
    required this.tooltip,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(3),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ComicsDetailsAwareLayout extends StatelessWidget {
  const ComicsDetailsAwareLayout({
    super.key,
    required this.content,
    required this.detailsLayout,
    required this.inspector,
  });

  final Widget content;
  final LibraryDetailsLayout detailsLayout;
  final Widget inspector;

  @override
  Widget build(BuildContext context) {
    return switch (detailsLayout) {
      LibraryDetailsLayout.right => Row(
          children: [
            Expanded(child: content),
            const VerticalDivider(width: 1),
            SizedBox(width: 340, child: inspector),
          ],
        ),
      LibraryDetailsLayout.bottom => Column(
          children: [
            Expanded(child: content),
            const Divider(height: 1),
            SizedBox(height: 310, child: inspector),
          ],
        ),
      LibraryDetailsLayout.hidden => content,
    };
  }
}
