import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/barcode/identifier_resolver.dart';

/// Kind-owned interpretation of a scanner value.
///
/// The barcode feature only captures and normalizes [ScannedCode]. This
/// contract identifies the owning kind without exposing kind semantics to the
/// generic scanner or lookup host.
abstract interface class LibraryBarcodeResolver
    implements IdentifierResolver<String> {
  CatalogMediaKind get kind;
}
