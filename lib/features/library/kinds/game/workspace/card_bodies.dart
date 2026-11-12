import 'package:collectarr_app/features/library/workspace/tiles/card_templates.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/dto.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card_footer.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card_presentation.dart';
import 'package:flutter/material.dart';

import 'platform_tile.dart';

String? _platform(LibraryCardBodyData data) {
  final dto = data.item.dto;
  final platform = dto is GameWorkspaceDto ? dto.platform?.trim() : null;
  return platform == null || platform.isEmpty ? null : platform;
}

/// Reference card: cover with its status in the corner, title, then the
/// platform tile and the value pill.
Widget buildGameVerticalCardBody(
    BuildContext context, LibraryCardBodyData data) {
  final platform = _platform(data);
  final value = data.presentation.valueLabel;
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
        child: Stack(fit: StackFit.expand, children: [
          data.buildCover(alignment: Alignment.topCenter),
          Positioned(right: 5, bottom: 5, child: data.coverStatus),
        ]),
      ),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: SizedBox(
        height: 57,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Text(data.item.dto.primaryLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: data.titleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.25)),
          ),
          Row(children: [
            if (platform != null) GamePlatformTile(platform),
            const SizedBox(width: 6),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: value == null ? null : LibraryCardValuePill(value),
              ),
            ),
          ]),
        ]),
      ),
    ),
  ]);
}

/// Reference card: cover, title and release date, the status at the top
/// right, then the platform tile and the value pill.
Widget buildGameHorizontalCardBody(
    BuildContext context, LibraryCardBodyData data) {
  final platform = _platform(data);
  final value = data.presentation.valueLabel;
  final detail = data.presentation.detailLine;
  return LibraryHorizontalCardLayout(
    data: data,
    details: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Text(data.item.dto.primaryLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16,
                  height: 1.15,
                  fontWeight: FontWeight.w400,
                  color: data.titleColor)),
        ),
        const SizedBox(width: 6),
        data.pillStatus,
      ]),
      if (detail?.isNotEmpty == true)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(detail!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: data.detailColor)),
        ),
      const Spacer(),
      Row(children: [
        if (platform != null) GamePlatformTile(platform),
        const SizedBox(width: 6),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: value == null ? null : LibraryCardValuePill(value),
          ),
        ),
      ]),
    ]),
  );
}
