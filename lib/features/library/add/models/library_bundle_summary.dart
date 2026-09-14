import 'package:collectarr_app/core/api/dto/bundle_release.dart';

/// Small mixed-Add projection for a bundle returned by the API.
///
/// The rich [BundleReleaseSummary] remains an API transport model. Add state
/// and generic selection UI only need stable identity and display data; they
/// must not carry publisher, region, edition or other kind-specific fields.
final class LibraryBundleSummary {
  const LibraryBundleSummary({
    required this.id,
    required this.title,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.memberCount = 0,
    this.primaryMemberCount = 0,
    this.bonusMemberCount = 0,
  });

  factory LibraryBundleSummary.fromTransport(BundleReleaseSummary bundle) {
    return LibraryBundleSummary(
      id: bundle.id,
      title: bundle.title,
      coverImageUrl: bundle.coverImageUrl,
      thumbnailImageUrl: bundle.thumbnailImageUrl,
      memberCount: bundle.contentSummary.totalItems,
      primaryMemberCount: bundle.contentSummary.primaryCount,
      bonusMemberCount: bundle.contentSummary.bonusCount,
    );
  }

  final String id;
  final String title;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final int memberCount;
  final int primaryMemberCount;
  final int bonusMemberCount;
}
