import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

CompilationUnit parseKindSource(File file) {
  final result = parseString(
    content: file.readAsStringSync(),
    path: file.path,
    throwIfDiagnostics: false,
  );
  final errors = result.errors.where(
    (error) => error.errorCode.errorSeverity.name == 'ERROR',
  );
  if (errors.isNotEmpty) {
    throw StateError('Could not parse ${file.path}: ${errors.first.message}');
  }
  return result.unit;
}

({String name, String? declaredType})? findTopLevelVariable(
  File file, {
  bool Function(String name)? nameWhere,
  bool Function(String? declaredType)? typeWhere,
}) {
  final unit = parseKindSource(file);
  for (final declaration
      in unit.declarations.whereType<TopLevelVariableDeclaration>()) {
    for (final variable in declaration.variables.variables) {
      final name = variable.name.lexeme;
      final declaredType = declaration.variables.type?.toSource() ??
          _initializerTypeSource(variable.initializer);
      if (nameWhere != null && !nameWhere(name)) continue;
      if (typeWhere != null && !typeWhere(declaredType)) continue;
      return (name: name, declaredType: declaredType);
    }
  }
  return null;
}

String? _initializerTypeSource(Expression? expression) {
  if (expression is InstanceCreationExpression) {
    return expression.constructorName.type.toSource();
  }
  if (expression is MethodInvocation && expression.target == null) {
    final source = expression.toSource();
    final match =
        RegExp(r'^([A-Za-z_]\w*(?:<[^>]+>)?)\s*\(').firstMatch(source);
    return match?.group(1);
  }
  return null;
}

String? findTopLevelClass(
  File file, {
  required bool Function(ClassDeclaration declaration) where,
}) {
  final unit = parseKindSource(file);
  for (final declaration in unit.declarations.whereType<ClassDeclaration>()) {
    if (where(declaration)) return declaration.namePart.typeName.lexeme;
  }
  return null;
}

List<String> findTableClasses(File file) {
  final unit = parseKindSource(file);
  return [
    for (final declaration in unit.declarations.whereType<ClassDeclaration>())
      if (declaration.extendsClause?.superclass.toSource() == 'Table')
        declaration.namePart.typeName.lexeme,
  ];
}

List<String> findClassesImplementing(File file, String expectedType) {
  final unit = parseKindSource(file);
  return [
    for (final declaration in unit.declarations.whereType<ClassDeclaration>())
      if (_classTypes(declaration).any(
        (type) => type == expectedType || type.startsWith('$expectedType<'),
      ))
        declaration.namePart.typeName.lexeme,
  ];
}

List<String> findClassNames(File file, bool Function(String name) where) {
  final unit = parseKindSource(file);
  return [
    for (final declaration in unit.declarations.whereType<ClassDeclaration>())
      if (where(declaration.namePart.typeName.lexeme))
        declaration.namePart.typeName.lexeme,
  ];
}

bool hasStaticConstField(ClassDeclaration declaration, String name) {
  return declaration.body.members.whereType<FieldDeclaration>().any(
        (field) =>
            field.isStatic &&
            field.fields.isConst &&
            field.fields.variables
                .any((variable) => variable.name.lexeme == name),
      );
}

Iterable<String> _classTypes(ClassDeclaration declaration) sync* {
  if (declaration.extendsClause case final clause?) {
    yield clause.superclass.toSource();
  }
  if (declaration.withClause case final clause?) {
    yield* clause.mixinTypes.map((type) => type.toSource());
  }
  if (declaration.implementsClause case final clause?) {
    yield* clause.interfaces.map((type) => type.toSource());
  }
}
