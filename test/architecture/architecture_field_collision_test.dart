import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/architecture/architecture_checker.dart';

void main() {
  test('collection lengths stay neutral while kind field accesses are caught',
      () {
    const source = """
int count(List<String> entries, String query) => entries.where((entry) => entry.isNotEmpty).length + query.trim().length;
dynamic value(dynamic Function() loadEntry) => loadEntry().rpm;
""";
    final parsed = parseString(content: source);
    final visitor = ArchitectureRuleVisitor(
      filePath: 'lib/features/library/generic/projection.dart',
      relativePath: 'lib/features/library/generic/projection.dart',
      lineInfo: parsed.lineInfo,
      isBoundaryFile: true,
      isRegistryFile: false,
      kindName: null,
      repoRoot: '.',
      sourceContent: source,
      kindEntryFieldSymbols: {'length', 'rpm'},
    );
    parsed.unit.accept(visitor);
    expect(visitor.kindFieldLeaks.map((finding) => finding.symbol), ['rpm']);
    expect(visitor.violations.any((message) => message.contains('"length"')),
        isFalse);
  });
}
