import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'contract_test_helpers.dart';

final class CoreFieldAdoptionPolicy {
  CoreFieldAdoptionPolicy({
    required this.dtoName,
    required this.mapped,
    required this.intentionallyIgnored,
  });

  final String dtoName;
  final Set<String> mapped;
  final Map<String, String> intentionallyIgnored;

  void validate(Iterable<String> actualFields) {
    final classified = {...mapped, ...intentionallyIgnored.keys};
    final unclassified =
        actualFields.where((field) => !classified.contains(field)).toSet();
    expectContract(
      unclassified.isEmpty,
      '$dtoName contains unclassified fields: ${unclassified.join(', ')}',
    );
    expectContract(
      mapped.intersection(intentionallyIgnored.keys.toSet()).isEmpty,
      '$dtoName cannot map and intentionally ignore the same field',
    );
  }
}

Set<String> coreDtoFieldNames({
  required String source,
  required String dtoName,
}) {
  final parseResult = parseString(content: source, throwIfDiagnostics: false);
  for (final declaration in parseResult.unit.declarations) {
    if (declaration is! ClassDeclaration ||
        declaration.namePart.toSource() != dtoName) {
      continue;
    }
    return {
      for (final field
          in declaration.body.members.whereType<FieldDeclaration>())
        for (final variable in field.fields.variables) variable.name.lexeme,
    };
  }
  throw StateError('Generated Core DTO "$dtoName" was not found');
}

void validateCoreDtoFieldAdoption({
  required String source,
  required CoreFieldAdoptionPolicy policy,
}) {
  policy.validate(
    coreDtoFieldNames(source: source, dtoName: policy.dtoName),
  );
}

void defineCoreFieldAdoptionContract({
  required String name,
  required CoreFieldAdoptionPolicy Function() createPolicy,
  required Iterable<String> Function(CoreFieldAdoptionPolicy policy)
      actualFields,
}) {
  defineTypedContract<CoreFieldAdoptionPolicy>(
    name: '$name core field adoption contract',
    create: createPolicy,
    checks: [
      (policy) => policy.validate(actualFields(policy)),
    ],
  );
}
