import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

class ComicsTopBar extends StatelessWidget {
  const ComicsTopBar({super.key, required this.totalCount});

  final int totalCount;

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
          const Icon(Icons.cloud_queue, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Collectarr Comics',
            style: TextStyle(fontWeight: FontWeight.w800),
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
