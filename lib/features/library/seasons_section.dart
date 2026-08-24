import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/hierarchy/ui/hierarchy_children_section.dart';
import 'package:flutter/material.dart';

class SeasonsSection extends StatelessWidget {
  const SeasonsSection({
    super.key,
    this.provider,
    this.providerItemId,
    this.itemId,
    this.kind,
  })  : assert(
          itemId != null || (provider != null && providerItemId != null),
          'Provide itemId or provider + providerItemId.',
        ),
        assert(
          itemId == null || (provider == null && providerItemId == null),
          'Use either itemId or provider + providerItemId.',
        );

  final String? provider;
  final String? providerItemId;
  final String? itemId;
  final String? kind;

  @override
  Widget build(BuildContext context) {
    final mediaKind = catalogMediaKindFromApiValue(kind ?? 'tv');
    return HierarchyChildrenSection(
      kind: mediaKind,
      itemId: itemId,
      provider: provider,
      providerItemId: providerItemId,
      canHydrateFromCore: true,
    );
  }
}
