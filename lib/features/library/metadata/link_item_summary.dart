import 'package:flutter/material.dart';

/// A cover, title and subtitle for one side of a Link row, with the facts
/// that decide a Core match under them.
class LinkItemSummary extends StatelessWidget {
  const LinkItemSummary(
      {super.key,
      required this.title,
      this.subtitle,
      this.imageUrl,
      this.imageSize = 45,
      this.details = const []});
  final double imageSize;
  final String title;
  final String? subtitle;
  final String? imageUrl;

  /// Labelled values, such as the barcode, shown under the subtitle.
  final List<(String, String)> details;
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (imageUrl?.isNotEmpty ?? false) ...[
          Image.network(imageUrl!,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  SizedBox.square(dimension: imageSize)),
          const SizedBox(width: 8),
        ],
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          if (subtitle?.isNotEmpty ?? false)
            Text(subtitle!, style: const TextStyle(fontSize: 14)),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 4),
            for (final (label, value) in details)
              Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: '$label: ',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: .7))),
                    TextSpan(text: value),
                  ]),
                  style: const TextStyle(fontSize: 13)),
          ],
        ])),
      ]);
}
