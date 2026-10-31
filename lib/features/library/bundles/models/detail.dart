import 'package:collectarr_app/core/api/dto/bundle_release.dart';

/// Structural bundle detail used by mixed Library UI.
///
/// Rich media-specific release fields are projected away before the generic
/// bundle renderer sees an API response.
final class LibraryBundleDetail {
  const LibraryBundleDetail({
    required this.id,
    required this.title,
    required this.memberCount,
    required this.primaryMemberCount,
    required this.bonusMemberCount,
    required this.members,
    this.coverImageUrl,
    this.thumbnailImageUrl,
  });

  factory LibraryBundleDetail.fromTransport(BundleReleaseDetail detail) {
    return LibraryBundleDetail(
      id: detail.id,
      title: detail.title,
      memberCount: detail.contentSummary.totalItems,
      primaryMemberCount: detail.contentSummary.primaryCount,
      bonusMemberCount: detail.contentSummary.bonusCount,
      coverImageUrl: detail.coverImageUrl,
      thumbnailImageUrl: detail.thumbnailImageUrl,
      members: [
        for (final member in detail.members)
          LibraryBundleMemberSummary.fromTransport(member),
      ],
    );
  }

  final String id;
  final String title;
  final int memberCount;
  final int primaryMemberCount;
  final int bonusMemberCount;
  final List<LibraryBundleMemberSummary> members;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
}

final class LibraryBundleMemberSummary {
  const LibraryBundleMemberSummary({
    required this.title,
    required this.role,
    required this.quantity,
    required this.isPrimary,
    this.sequenceNumber,
  });

  factory LibraryBundleMemberSummary.fromTransport(
    BundleReleaseMember member,
  ) {
    return LibraryBundleMemberSummary(
      title: member.title,
      role: member.role,
      quantity: member.quantity,
      isPrimary: member.isPrimary,
      sequenceNumber: member.sequenceNumber,
    );
  }

  final String title;
  final String role;
  final int quantity;
  final bool isPrimary;
  final int? sequenceNumber;
}
