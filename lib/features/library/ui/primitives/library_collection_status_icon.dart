import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Collection status artwork shared by filters and Add actions.
class LibraryCollectionStatusIcon extends StatelessWidget {
  const LibraryCollectionStatusIcon(
      {super.key, required this.collectionStatus, this.size = 20});

  final LibraryCollectionStatusScope collectionStatus;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = switch (collectionStatus) {
      LibraryCollectionStatusScope.all => 'all',
      LibraryCollectionStatusScope.inCollection => 'incollection',
      LibraryCollectionStatusScope.forSale => 'forsale',
      LibraryCollectionStatusScope.wishList => 'wishlist',
      LibraryCollectionStatusScope.onOrder => 'onorder',
      LibraryCollectionStatusScope.sold => 'sold',
      LibraryCollectionStatusScope.notInCollection => 'notincollection',
    };
    final background =
        collectionStatus.colorFor(LibraryAccentScope.accentOf(context));
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .08),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(3)),
      child: SvgPicture.asset(
        'assets/collection_status/collection-status-$asset.svg',
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}
