import 'contract_test_helpers.dart';

void defineTrackingContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required String Function(TSubject subject) state,
  required num Function(TSubject subject) progress,
}) {
  defineTypedContract<TSubject>(
    name: '$name tracking contract',
    create: create,
    checks: [
      (subject) =>
          expectNonEmpty(state(subject), '$name tracking needs a state'),
      (subject) => expectContract(
            progress(subject) >= 0,
            '$name tracking progress cannot be negative',
          ),
    ],
  );
}
