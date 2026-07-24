export 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_release.dart';

// Transitional typedefs to avoid parallel domain models while existing components migrate.
typedef BookWork = BookCatalogItem;
typedef BookEdition = BookRelease;
typedef BookVariant = BookVariantRef;
