import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/architecture/architecture_checker.dart';

List<String> violations(String source) {
  final parsed = parseString(content: source);
  final visitor = ArchitectureRuleVisitor(
    filePath: '${Directory.current.path}/lib/example.dart',
    relativePath: 'lib/example.dart',
    lineInfo: parsed.lineInfo,
    isBoundaryFile: false,
    isRegistryFile: false,
    kindName: null,
    repoRoot: Directory.current.path,
  );
  parsed.unit.accept(visitor);
  return visitor.violations.where((v) => v.startsWith('TK023')).toList();
}

void main() {
  for (final name in [
    'LibraryMetadataItem',
    'LibraryCatalogItemView',
    'LibraryKindMetadataRuntime',
    'CatalogKindCodec',
    'KindEditDraft',
    'LibrarySectionRegistry',
    'DefaultLibraryEditPresentationBuilder',
    'CatalogCache',
    'LibraryEditCapability',
    'collectarrKindEdits',
    'MetadataOverrideFieldOption',
  ]) {
    test('runtime ownership rejects $name', () {
      expect(violations('void main() { $name(); }'), isNotEmpty);
    });
  }
  test('ownership rule rejects erased type declarations and annotations', () {
    expect(violations('class CatalogCache {}'), isNotEmpty);
    expect(violations('void use(CatalogCache cache) {}'), isNotEmpty);
  });
  test('ownership rule ignores documentation and string values', () {
    expect(
        violations(
            '// CatalogCache was removed.\nconst label = "CatalogCache";'),
        isEmpty);
  });
}
