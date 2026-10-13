import 'contract_test_helpers.dart';

void defineCoreMappingContract<TDomain, TDto>({
  required String name,
  required TDomain Function() createDomain,
  required TDto Function(TDomain domain) encode,
  required TDomain Function(TDto dto) decode,
  required bool Function(TDomain left, TDomain right) equals,
}) {
  defineTypedContract<TDomain>(
    name: '$name core mapping contract',
    create: createDomain,
    checks: [
      (domain) {
        final roundTrip = decode(encode(domain));
        expectContract(
          equals(domain, roundTrip),
          '$name core mapping must preserve the typed domain value',
        );
      },
    ],
  );
}
