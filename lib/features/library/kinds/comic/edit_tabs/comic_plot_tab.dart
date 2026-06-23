import 'package:flutter/material.dart';

class ComicPlotTab extends StatelessWidget {
  const ComicPlotTab({
    super.key,
    required this.summaryController,
  });

  final TextEditingController summaryController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: summaryController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Plot / Synopsis',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(),
              ),
              key: const ValueKey('edit-plot'),
            ),
          ),
        ],
      ),
    );
  }
}
