import 'dart:async';

import '../contract_test_helpers.dart';

void defineBarcodeResolverContract<TResolver, TCode, TResult>({
  required String name,
  required TResolver Function() create,
  required TCode Function(TResolver resolver, TCode code) normalize,
  required bool Function(TResolver resolver, TCode code) isSupported,
  required FutureOr<TResult?> Function(TResolver resolver, TCode code) resolve,
  required TCode Function() validCode,
  required TCode Function() unsupportedCode,
  required bool Function(TResult result) isValidResult,
}) {
  defineAsyncTypedContract<TResolver>(
    name: '$name barcode resolver contract',
    create: create,
    check: (resolver) async {
      final valid = validCode();
      final normalized = normalize(resolver, valid);
      expectContract(
        normalize(resolver, normalized) == normalized,
        '$name barcode normalization must be idempotent',
      );
      expectContract(
        isSupported(resolver, normalized),
        '$name valid barcode must be supported',
      );
      final result = await resolve(resolver, normalized);
      expectContract(
        result != null && isValidResult(result as TResult),
        '$name valid barcode must resolve to a valid result',
      );

      final unsupported = unsupportedCode();
      expectContract(
        !isSupported(resolver, unsupported),
        '$name unsupported barcode must be rejected',
      );
      expectSame(
        await resolve(resolver, unsupported),
        null,
        '$name unsupported barcode must not resolve',
      );
    },
  );
}
