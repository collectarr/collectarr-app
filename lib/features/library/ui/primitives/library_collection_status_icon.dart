import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Collection status artwork shared by filters and Add actions.
class LibraryCollectionStatusIcon extends StatelessWidget {
  const LibraryCollectionStatusIcon(
      {super.key, required this.status, this.size = 20});

  final LibraryCollectionStatusScope status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (asset, background) = switch (status) {
      LibraryCollectionStatusScope.all => ('all', const Color(0xFF777777)),
      LibraryCollectionStatusScope.inCollection => (
          'incollection',
          const Color(0xFF2AA4CC)
        ),
      LibraryCollectionStatusScope.forSale => (
          'forsale',
          const Color(0xFF2D7427)
        ),
      LibraryCollectionStatusScope.wishList => (
          'wishlist',
          const Color(0xFFFF9B00)
        ),
      LibraryCollectionStatusScope.onOrder => (
          'onorder',
          const Color(0xFF13627F)
        ),
      LibraryCollectionStatusScope.sold => ('sold', const Color(0xFFA63131)),
      LibraryCollectionStatusScope.notInCollection => (
          'notincollection',
          const Color(0xFF777777)
        ),
    };
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
