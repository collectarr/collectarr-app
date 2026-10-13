import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';
import 'package:collectarr_app/features/library/config/library_barcode_resolver.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'barcode_contract.dart';

void main() {
  const retailCode = ScannedCode(
    rawValue: '012345678905',
    value: '012345678905',
    symbology: ScannedCodeSymbology.upcA,
  );
  const isbn13 = ScannedCode(
    rawValue: '9780306406157',
    value: '9780306406157',
    symbology: ScannedCodeSymbology.ean13,
  );
  const invalidCode = ScannedCode(
    rawValue: 'not-a-code',
    value: 'NOTACODE',
    symbology: ScannedCodeSymbology.unknown,
  );

  for (final resolver in libraryBarcodeResolvers) {
    defineBarcodeResolverContract<LibraryBarcodeResolver, ScannedCode, String>(
      name: resolver.kind.apiValue,
      create: () => resolver,
      normalize: (_, code) =>
          ScannedCode.tryFromRaw(
            code.rawValue,
            symbology: code.symbology,
          ) ??
          code,
      isSupported: (subject, code) => subject.resolve(code) != null,
      resolve: (subject, code) => subject.resolve(code),
      validCode: () => isbn13,
      unsupportedCode: () => invalidCode,
      isValidResult: (result) => result == isbn13.value,
    );
  }

  test('only the released Music barcode resolver is registered', () {
    expect(libraryBarcodeResolvers.map((resolver) => resolver.kind).toSet(),
        {CatalogMediaKind.music});
  });

  test('barcode dispatch normalizes before invoking the owning resolver', () {
    expect(
      resolveLibraryBarcodeForKind(
        CatalogMediaKind.music,
        '012-345-678-905',
      ),
      retailCode.value,
    );
    expect(
      resolveLibraryBarcodeForKind(CatalogMediaKind.music, isbn13.rawValue),
      isbn13.value,
    );
    expect(
      resolveLibraryBarcodeForKind(CatalogMediaKind.unknown, retailCode.value),
      isNull,
    );
  });
}
