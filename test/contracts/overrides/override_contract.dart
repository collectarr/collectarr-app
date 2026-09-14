import '../contract_test_helpers.dart';

void defineMetadataOverrideContract<TSchema, TTarget, TField, TValue>({
  required String name,
  required TSchema Function() create,
  required TTarget Function(TSchema schema) target,
  required TField Function(TSchema schema) field,
  required String Function(TField field) fieldId,
  required TValue Function() value,
  required Object? Function(TSchema schema, TValue value) encode,
  required TValue Function(TSchema schema, Object? payload) decode,
  required bool Function(TSchema schema, TTarget target) isValidTarget,
  required bool Function(TValue left, TValue right) equals,
}) {
  defineTypedContract<TSchema>(
    name: '$name metadata override contract',
    create: create,
    checks: [
      (schema) {
        final overrideTarget = target(schema);
        expectContract(
          isValidTarget(schema, overrideTarget),
          '$name override target must be valid',
        );
        expectNonEmpty(
          fieldId(field(schema)),
          '$name override field ID must not be empty',
        );

        final original = value();
        final restored = decode(schema, encode(schema, original));
        expectContract(
          equals(original, restored),
          '$name override value must round-trip through its codec',
        );
      },
    ],
  );
}
