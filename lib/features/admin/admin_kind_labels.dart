import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/v1/catalog_item_v1_kind_identities.dart';

String? adminKindLabelForType(
  CatalogMediaKind kind, {
  required bool plural,
}) {
  if (kind.isUnknown) return null;
  final identity = catalogItemV1KindIdentities[kind];
  if (identity == null) return null;
  return plural ? identity.pluralLabel : identity.singularLabel;
}

String adminFallbackKindLabel(String kind) =>
    kind.isEmpty ? 'Unknown' : '${kind[0].toUpperCase()}${kind.substring(1)}';

String adminMediaTypeDisplayLabel(CatalogMediaType type) {
  return adminKindLabelForType(
        catalogMediaKindFromApiValue(type.kind),
        plural: true,
      ) ??
      (type.pluralLabel.isNotEmpty ? type.pluralLabel : type.kind);
}

int compareAdminMediaKinds(
  String left,
  String right,
  Map<String, String> labels,
) {
  String labelFor(String kind) => labels[kind]?.trim().isNotEmpty == true
      ? labels[kind]!
      : adminFallbackKindLabel(kind);
  return labelFor(left).compareTo(labelFor(right));
}
