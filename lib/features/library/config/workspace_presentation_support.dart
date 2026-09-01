import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

String defaultLibraryBucketLabel(
  LibraryBucketingContext context,
  LibraryMediaGroupLabels labels, [
  LibraryBucketLabelOverrides overrides = const LibraryBucketLabelOverrides(),
]) {
  final mode = _unqualifiedGroupMode(context.groupId.value);
  final explicitOverride = overrides.labelFor(mode);
  if (explicitOverride.isNotEmpty) {
    return explicitOverride;
  }

  return switch (context.groupId.semantic) {
    LibraryGroupSemantic.title => _titleBucket(context.item.dto.title),
    LibraryGroupSemantic.location =>
      _locationBucket(context.source.locationPath),
    LibraryGroupSemantic.ownership => context.source.isOwned
        ? overrides.labelFor('owned', fallback: 'Owned')
        : context.source.isWishlisted
            ? overrides.labelFor('wishlist', fallback: 'Wishlist')
            : overrides.labelFor('catalog_only', fallback: 'Catalog only'),
    _ => overrides.labelFor(
        'unknown_$mode',
        fallback: labels.labelFor(
          'unknown_$mode',
          fallback: labels.labelFor(mode, fallback: mode),
        ),
      ),
  };
}

String _unqualifiedGroupMode(String mode) {
  final separator = mode.lastIndexOf('.');
  return separator < 0 ? mode : mode.substring(separator + 1);
}

String _locationBucket(String? location) {
  final normalized = location?.trim();
  if (normalized == null || normalized.isEmpty) {
    return 'No location';
  }
  return normalized;
}

String _titleBucket(String title) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? 'Unknown' : trimmed.substring(0, 1).toUpperCase();
}
