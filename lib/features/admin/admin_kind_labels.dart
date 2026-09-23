import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

String? adminKindLabelForType(
  CatalogMediaKind kind, {
  required bool plural,
}) {
  if (kind.isUnknown) return null;
  final identity = defaultLibraryKindRegistry.tryGet(kind)?.identity;
  if (identity == null) return null;
  return plural ? identity.pluralLabel : identity.singularLabel;
}

String adminFallbackKindLabel(String kind) =>
    kind.isEmpty ? 'Unknown' : '${kind[0].toUpperCase()}${kind.substring(1)}';

String adminProviderKindLabel(
  String kind,
  Map<String, String> labels,
) {
  final label = labels[kind];
  if (label != null && label.isNotEmpty) {
    return label;
  }
  final mediaKind = catalogMediaKindFromApiValue(kind);
  return adminKindLabelForType(mediaKind, plural: false) ??
      adminFallbackKindLabel(kind);
}

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
  return adminProviderKindLabel(left, labels).compareTo(
    adminProviderKindLabel(right, labels),
  );
}
