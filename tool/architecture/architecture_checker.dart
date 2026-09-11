import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:path/path.dart' as p;

import 'migration_exceptions.dart';

class ArchitectureRuleVisitor extends RecursiveAstVisitor<void> {
  ArchitectureRuleVisitor({
    required this.filePath,
    required this.relativePath,
    required this.lineInfo,
    required this.isBoundaryFile,
    required this.isRegistryFile,
    required this.kindName,
    required this.repoRoot,
    this.sourceContent,
  });

  final String filePath;
  final String relativePath;
  final LineInfo lineInfo;
  final bool isBoundaryFile;
  final bool isRegistryFile;
  final String? kindName;
  final String repoRoot;
  final String? sourceContent;

  final List<String> violations = [];
  final List<String> complexityWarnings = [];

  static const _forbiddenKindDomainTypes = {
    // Comic
    'ComicCatalogMetadata',
    'ComicMetadata',
    'ComicWorkspaceDto',
    'ComicCatalogItem',
    'ComicOwnedDetails',
    'ComicStoryArc',
    'ComicGrade',
    'ComicKeyDraft',
    'ComicKeyReason',
    'ComicMedia',
    'ComicRelease',
    'ComicOwnedItem',
    // Movie & Video
    'MovieCatalogMetadata',
    'MovieWorkspaceDto',
    'MovieCatalogItem',
    'MovieOwnedDetails',
    // Tv
    'TvCatalogMetadata',
    'TvSeriesMetadata',
    'TvWorkspaceDto',
    'TvCatalogItem',
    'TvOwnedDetails',
    // Anime
    'AnimeCatalogMetadata',
    'AnimeMetadata',
    'AnimeWorkspaceDto',
    'AnimeCatalogItem',
    'AnimeOwnedDetails',
    // Book
    'BookCatalogMetadata',
    'BookWorkspaceDto',
    'BookCatalogItem',
    'BookOwnedDetails',
    // Manga
    'MangaCatalogMetadata',
    'MangaMetadata',
    'MangaWorkspaceDto',
    'MangaCatalogItem',
    'MangaOwnedDetails',
    // Game
    'GameCatalogMetadata',
    'GameWorkspaceDto',
    'GameCatalogItem',
    'GameOwnedDetails',
    // BoardGame
    'BoardGameMetadata',
    'BoardGameWorkspaceDto',
    'BoardGameCatalogItem',
    'BoardgameOwnedDetails',
    // Music
    'MusicCatalogMetadata',
    'MusicWorkspaceDto',
    'MusicCatalogItem',
    'MusicOwnedDetails',
  };

  static const _forbiddenContextualMemberNames = {
    // Domain vocabulary that must not be interpreted by a generic feature
    // after kind dispatch.  Provider protocol models and kind-owned files are
    // excluded by the path checks below.
    'series',
    'issue',
    'issueNumber',
    'volume',
    'chapter',
    'season',
    'episode',
    'publisher',
    'imprint',
    'isbn',
    'barcode',
    'grade',
    'grading',
    'hdr',
    'audio',
    'platform',
    'region',
    'creator',
    'character',
    'track',
    'storyArc',
    'storyArcs',
    'comicGrade',
    'keyComic',
    'keyReason',
    'rawOrSlabbed',
    'gradingCompany',
    'graderNotes',
    'showsOwnedGradingSection',
    'showsComicCollectorFields',
    'showsGameCompletenessFields',
    'showsOwnedCoverPriceField',
    'keyToggleLabel',
    'keyReasonLabel',
    'seriesHierarchy',
    'episodesVolumesTracks',
    'supportsTrackSearch',
    'defaultVideoDisplayLevel',
    'defaultVideoGrouping',
    'videoSeriesEntryTypes',
    'videoShelfDrilldownEntryTypes',
    'creatorsSummary',
    'physicalFormatLabel',
  };

  static const _forbiddenRuntimeTypeNames = {
    'CatalogItemDto',
    'LibraryKindMetadataRuntime',
    'LibraryMetadataItem',
    'LibraryCatalogItemView',
  };

  static final _genericMetadataMapAllowlist =
      architectureExceptionPaths('TK003');

  static final _dynamicCatalogAllowlist = architectureExceptionPaths('TK009');

  static final _generatedDtoAllowlist = architectureExceptionPaths('TK006');

  static final _structuralProjectionAllowlist =
      architectureExceptionPaths('TK010');

  // The enum implementation itself may compare enum values while parsing its
  // serialized representation. This is not generic feature dispatch.
  static final _structuralKindComparisonAllowlist =
      architectureExceptionPaths('TK005-comparison');

  // These models switch over their own structural event enum to provide
  // labels/icons/colors. They do not dispatch catalog semantics by kind.
  static final _structuralKindSwitchAllowlist =
      architectureExceptionPaths('TK005-switch');

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (_isStrictGenericContext(relativePath)) {
      final propertyName = node.propertyName.name;
      final isFlutterThemePlatform = propertyName == 'platform' &&
          node.target?.toSource().startsWith('Theme.of(') == true;
      if (_forbiddenContextualMemberNames.contains(propertyName) &&
          !isFlutterThemePlatform) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          'TK010 $relativePath:$line: Forbidden contextual semantic member access "$propertyName" in generic library code',
        );
      }
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_isStrictGenericContext(relativePath)) {
      final methodName = node.methodName.name;
      if (_forbiddenContextualMemberNames.contains(methodName)) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          'TK010 $relativePath:$line: Forbidden contextual semantic method/getter call "$methodName" in generic library code',
        );
      }
    }
    super.visitMethodInvocation(node);
  }

  bool _isStrictGenericContext(String path) {
    if (path.startsWith('lib/features/library/kinds/') ||
        path.startsWith('lib/features/catalog/transport/') ||
        path.startsWith('lib/features/providers/') ||
        path.startsWith('lib/core/api/generated/')) {
      return false;
    }
    return path.startsWith('lib/features/') ||
        path.startsWith('lib/core/models/') ||
        path.startsWith('lib/core/api/mappers/');
  }

  @override
  void visitImportDirective(ImportDirective node) {
    _checkDirective(node.uri.stringValue, node.offset, 'import');
    super.visitImportDirective(node);
  }

  @override
  void visitExportDirective(ExportDirective node) {
    _checkDirective(node.uri.stringValue, node.offset, 'export');
    super.visitExportDirective(node);
  }

  void _checkDirective(String? uriString, int offset, String directive) {
    if (uriString == null) return;
    if (isRegistryFile) return;

    final lineNumber = lineInfo.getLocation(offset).lineNumber;
    final importedPath = _resolveImportPath(repoRoot, filePath, uriString);
    if (importedPath == null) return;

    final importedRelativePath =
        p.relative(importedPath, from: repoRoot).replaceAll('\\', '/');

    if (_isProviderPath(relativePath) &&
        importedRelativePath.startsWith('lib/features/library/kinds/')) {
      violations.add(
        'TK007 $relativePath:$lineNumber: Provider code must not import kind-specific modules ($uriString)',
      );
      return;
    }

    if (_isGeneratedCoreDtoPath(importedRelativePath) &&
        !_generatedDtoAllowlist.contains(relativePath)) {
      violations.add(
        'TK006 $relativePath:$lineNumber: Generated Core DTO import must stay inside the owning kind module ($uriString)',
      );
      return;
    }

    if (!importedRelativePath.startsWith('lib/features/library/kinds/')) {
      return;
    }
    if (importedRelativePath
        .startsWith('lib/features/library/kinds/registry/')) {
      return;
    }
    if (isBoundaryFile) {
      violations.add(
        'TK001 $relativePath:$lineNumber: Forbidden import of kind-specific module ($uriString) from generic boundary code',
      );
      return;
    }

    if (kindName != null) {
      final importedKind = _kindNameForPath(importedRelativePath);
      if (importedKind != null &&
          importedKind != kindName &&
          !isAllowedKindImport(kindName!, importedKind)) {
        violations.add(
          'TK008 $relativePath:$lineNumber: Cross-kind import violation ($directive $uriString)',
        );
      }
    }
  }

  @override
  void visitNamedType(NamedType node) {
    if (_forbiddenRuntimeTypeNames.contains(node.name.lexeme) &&
        _isForbiddenRuntimeTypeContext(relativePath)) {
      final line = lineInfo.getLocation(node.offset).lineNumber;
      violations.add(
        'TK002 $relativePath:$line: Erased runtime type "${node.name.lexeme}" must stay out of feature layers',
      );
    }

    if (_isGenericMetadataMap(node) &&
        !_genericMetadataMapAllowlist.contains(relativePath)) {
      final line = lineInfo.getLocation(node.offset).lineNumber;
      violations.add(
        'TK003 $relativePath:$line: Generic metadata map must be classified or moved to a kind-owned mapper',
      );
    }

    if (_isDynamicCatalogType(node) &&
        !_dynamicCatalogAllowlist.contains(relativePath)) {
      final line = lineInfo.getLocation(node.offset).lineNumber;
      violations.add(
        'TK009 $relativePath:$line: Dynamic catalog/metadata object must be replaced or explicitly allowlisted',
      );
    }

    if (isBoundaryFile) {
      final typeName = node.name.lexeme;
      if (_forbiddenKindDomainTypes.contains(typeName)) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          'TK004 $relativePath:$line: Forbidden concrete kind domain type "$typeName" in generic boundary code',
        );
      }
      if (typeName == 'LibraryFieldRegistry') {
        final typeArgs = node.typeArguments?.arguments;
        if (typeArgs != null &&
            typeArgs.isNotEmpty &&
            (typeArgs.first.toSource() == 'dynamic' ||
                typeArgs.first.toSource() == 'Object?')) {
          final line = lineInfo.getLocation(node.offset).lineNumber;
          violations.add(
            'TK004 $relativePath:$line: Forbidden dynamic field registry "LibraryFieldRegistry<dynamic>" in generic boundary code',
          );
        }
      }
    }
    super.visitNamedType(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (isBoundaryFile) {
      final idName = node.name;
      if (_forbiddenKindDomainTypes.contains(idName)) {
        final parent = node.parent;
        // Don't duplicate if already caught as NamedType
        if (parent is! NamedType) {
          final line = lineInfo.getLocation(node.offset).lineNumber;
          violations.add(
            'TK004 $relativePath:$line: Forbidden concrete kind reference "$idName" in generic boundary code',
          );
        }
      }
    }
    super.visitSimpleIdentifier(node);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    if (isBoundaryFile &&
        !_structuralKindSwitchAllowlist.contains(relativePath)) {
      if (_isCatalogKindDispatchExpression(node.expression.toSource())) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          'TK005 $relativePath:$line: Forbidden CatalogMediaKind switch statement in generic boundary code',
        );
      }
    }
    super.visitSwitchStatement(node);
  }

  @override
  void visitSwitchExpression(SwitchExpression node) {
    if (isBoundaryFile &&
        !_structuralKindSwitchAllowlist.contains(relativePath)) {
      if (_isCatalogKindDispatchExpression(node.expression.toSource())) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          'TK005 $relativePath:$line: Forbidden CatalogMediaKind switch expression in generic boundary code',
        );
      }
    }
    super.visitSwitchExpression(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (isBoundaryFile &&
        !_structuralKindComparisonAllowlist.contains(relativePath) &&
        (node.operator.lexeme == '==' || node.operator.lexeme == '!=')) {
      final left = node.leftOperand.toSource();
      final right = node.rightOperand.toSource();
      if (left.contains('CatalogMediaKind.') ||
          right.contains('CatalogMediaKind.')) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          'TK005 $relativePath:$line: Forbidden CatalogMediaKind comparison in generic boundary code',
        );
      }
    }
    super.visitBinaryExpression(node);
  }

  bool _isCatalogKindDispatchExpression(String expression) {
    if (expression.contains('CatalogMediaKind')) return true;
    final source = sourceContent;
    if (source == null) return false;
    final catalogKindVariables = RegExp(
      r'\bCatalogMediaKind\??\s+([A-Za-z_]\w*)',
    ).allMatches(source).map((match) => match.group(1)!);
    return catalogKindVariables.any(
      (name) => RegExp('\\b${RegExp.escape(name)}\\b').hasMatch(expression),
    );
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final startLine = lineInfo.getLocation(node.offset).lineNumber;
    final endLine = lineInfo.getLocation(node.end).lineNumber;
    final classLength = endLine - startLine + 1;
    final className = node.namePart.toSource();
    if (classLength > 500 && !_isExempt(relativePath)) {
      complexityWarnings.add(
        'CX002 $relativePath:$startLine: Class "$className" exceeds complexity budget ($classLength > 500 lines)',
      );
    }
    super.visitClassDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkDeclaredSemanticName(node.name.lexeme, node.offset);
    final startLine = lineInfo.getLocation(node.offset).lineNumber;
    final endLine = lineInfo.getLocation(node.end).lineNumber;
    final methodLength = endLine - startLine + 1;
    if (methodLength > 100 && !_isExempt(relativePath)) {
      complexityWarnings.add(
        'CX003 $relativePath:$startLine: Method "${node.name.lexeme}" exceeds complexity budget ($methodLength > 100 lines)',
      );
    }
    _checkParameters(node.parameters, node.name.lexeme, startLine);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (node.parent?.parent is FieldDeclaration) {
      _checkDeclaredSemanticName(node.name.lexeme, node.offset);
    }
    super.visitVariableDeclaration(node);
  }

  void _checkDeclaredSemanticName(String name, int offset) {
    if (!_isStrictGenericContext(relativePath) ||
        _structuralProjectionAllowlist.contains(relativePath) ||
        !_forbiddenContextualMemberNames.contains(name)) {
      return;
    }
    final line = lineInfo.getLocation(offset).lineNumber;
    violations.add(
      'TK010 $relativePath:$line: Forbidden contextual semantic declaration "$name" in generic library code',
    );
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final startLine = lineInfo.getLocation(node.offset).lineNumber;
    final endLine = lineInfo.getLocation(node.end).lineNumber;
    final funcLength = endLine - startLine + 1;
    if (funcLength > 100 && !_isExempt(relativePath)) {
      complexityWarnings.add(
        'CX003 $relativePath:$startLine: Function "${node.name.lexeme}" exceeds complexity budget ($funcLength > 100 lines)',
      );
    }
    _checkParameters(
      node.functionExpression.parameters,
      node.name.lexeme,
      startLine,
    );
    super.visitFunctionDeclaration(node);
  }

  void _checkParameters(
    FormalParameterList? parameters,
    String callableName,
    int line,
  ) {
    if (parameters != null && parameters.parameters.length > 18) {
      complexityWarnings.add(
        'CX004 $relativePath:$line: Callable "$callableName" exceeds parameter budget (${parameters.parameters.length} > 18 params)',
      );
    }
  }

  bool _isExempt(String path) {
    return path.endsWith('.g.dart') ||
        path.endsWith('.freezed.dart') ||
        path.endsWith('.drift.dart') ||
        path.contains('/generated/');
  }

  bool _isGenericMetadataMap(NamedType node) {
    if (node.name.lexeme != 'Map' || !_isProductionBoundaryPath(relativePath)) {
      return false;
    }
    final arguments = node.typeArguments?.arguments;
    if (arguments == null || arguments.length != 2) return false;
    final keyType = arguments[0].toSource();
    final valueType = arguments[1].toSource();
    if (keyType != 'String' ||
        (valueType != 'dynamic' && valueType != 'Object?')) {
      return false;
    }
    final lineNumber = lineInfo.getLocation(node.offset).lineNumber;
    final lines = sourceContent?.split('\n');
    final declarationSource = lines != null && lineNumber <= lines.length
        ? lines[lineNumber - 1]
        : node.toSource();
    return RegExp(
      r'\b(metadata|catalog|payload|semantic|details|owned|release|item)\b',
      caseSensitive: false,
    ).hasMatch(declarationSource);
  }

  bool _isDynamicCatalogType(NamedType node) {
    if (node.name.lexeme != 'dynamic' ||
        !_isProductionBoundaryPath(relativePath)) {
      return false;
    }
    final lineNumber = lineInfo.getLocation(node.offset).lineNumber;
    final lines = sourceContent?.split('\n');
    final declarationSource = lines != null && lineNumber <= lines.length
        ? lines[lineNumber - 1]
        : node.parent?.parent?.toSource() ?? '';
    return RegExp(
      r'\b(catalog|metadata|payload|item)[A-Za-z0-9_]*\b',
      caseSensitive: false,
    ).hasMatch(declarationSource);
  }

  bool _isForbiddenRuntimeTypeContext(String path) {
    return _isProductionBoundaryPath(path) ||
        path.startsWith('lib/core/models/') ||
        path.startsWith('lib/core/api/mappers/');
  }

  bool _isProductionBoundaryPath(String path) {
    return path.startsWith('lib/features/') &&
            !path.startsWith('lib/features/library/kinds/') &&
            !path.startsWith('lib/features/catalog/transport/') &&
            !path.startsWith('lib/features/providers/') ||
        path.startsWith('lib/core/models/') ||
        path.startsWith('lib/core/api/mappers/') ||
        path.startsWith('lib/core/routing/') ||
        path.startsWith('lib/core/settings/');
  }
}

const _registryRoot = 'lib/features/library/kinds/registry/';

List<String> architectureAllowlistIntegrityErrors(String repoRoot) {
  final allowlists = <String, Set<String>>{
    'generic metadata maps':
        ArchitectureRuleVisitor._genericMetadataMapAllowlist,
    'dynamic catalog values': ArchitectureRuleVisitor._dynamicCatalogAllowlist,
    'generated DTO imports': ArchitectureRuleVisitor._generatedDtoAllowlist,
    'structural projections':
        ArchitectureRuleVisitor._structuralProjectionAllowlist,
    'structural kind switches':
        ArchitectureRuleVisitor._structuralKindSwitchAllowlist,
    'structural kind comparisons':
        ArchitectureRuleVisitor._structuralKindComparisonAllowlist,
  };
  final errors = <String>[];
  errors.addAll(architectureMigrationExceptionIntegrityErrors());
  for (final entry in allowlists.entries) {
    for (final relativePath in entry.value) {
      final file = File(p.join(repoRoot, relativePath));
      if (!file.existsSync()) {
        errors.add('${entry.key}: missing allowlisted file $relativePath');
        continue;
      }
    }
  }
  return errors;
}

void runArchitectureChecker([List<String> arguments = const []]) {
  final repoRoot = Directory.current.path;
  final libRoot = p.join(repoRoot, 'lib');
  final files = _dartFilesUnder(Directory(libRoot)).toList()..sort();

  final allViolations = <String>[];
  final allComplexityWarnings = <String>[];

  allViolations.addAll(
    architectureAllowlistIntegrityErrors(repoRoot).map(
      (error) => 'architecture allowlist: $error',
    ),
  );

  for (final file in files) {
    final relativePath = p.relative(file, from: repoRoot).replaceAll('\\', '/');
    if (_isGeneratedSourcePath(relativePath) ||
        relativePath.endsWith('.g.dart') ||
        relativePath.endsWith('.freezed.dart') ||
        relativePath.endsWith('.drift.dart')) {
      continue;
    }

    final isRegistryFile = relativePath.startsWith(_registryRoot);
    final kindName = _kindNameForPath(relativePath);
    final isBoundary = isBoundaryFile(relativePath);

    final content = File(file).readAsStringSync();
    final lineCount = content.split('\n').length;
    if (lineCount > 800) {
      allComplexityWarnings.add(
        'CX001 $relativePath: File exceeds complexity budget ($lineCount > 800 lines)',
      );
    }

    final parseResult = parseString(
      content: content,
      path: file,
      throwIfDiagnostics: false,
    );

    final visitor = ArchitectureRuleVisitor(
      filePath: file,
      relativePath: relativePath,
      lineInfo: parseResult.lineInfo,
      isBoundaryFile: isBoundary,
      isRegistryFile: isRegistryFile,
      kindName: kindName,
      repoRoot: repoRoot,
      sourceContent: content,
    );

    parseResult.unit.accept(visitor);
    allViolations.addAll(visitor.violations);
    allComplexityWarnings.addAll(visitor.complexityWarnings);
  }

  if (allViolations.isNotEmpty) {
    stderr.writeln('AST Architecture violations (${allViolations.length}):');
    for (final violation in allViolations) {
      stderr.writeln('  $violation');
    }
    exitCode = 1;
  } else {
    stdout.writeln('No AST architecture boundary violations found.');
  }

  if (allComplexityWarnings.isNotEmpty) {
    stdout.writeln(
      'Complexity budget reports (${allComplexityWarnings.length}):',
    );
    for (final warning in allComplexityWarnings.take(15)) {
      stdout.writeln('  $warning');
    }
    if (allComplexityWarnings.length > 15) {
      stdout.writeln('  ... and ${allComplexityWarnings.length - 15} more');
    }
  }
}

Iterable<String> _dartFilesUnder(Directory root) sync* {
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.toLowerCase().endsWith('.dart')) {
      yield entity.path;
    }
  }
}

bool isBoundaryFile(String relativePath) {
  if (!relativePath.startsWith('lib/')) {
    return false;
  }
  if (relativePath.startsWith('lib/test/') ||
      relativePath.startsWith('lib/dev/') ||
      relativePath.startsWith('lib/features/library/kinds/') ||
      relativePath.startsWith('lib/core/api/generated/') ||
      _compositionRoots.contains(relativePath)) {
    return false;
  }
  return true;
}

const _compositionRoots = {
  'lib/core/db/local_database.dart',
  'lib/core/routing/app_router.dart',
  'lib/features/library/library_kind_registry.dart',
};

bool isAllowedKindImport(String sourceKind, String importedKind) {
  return false;
}

bool _isProviderPath(String relativePath) {
  return relativePath.startsWith('lib/features/providers/');
}

bool _isGeneratedCoreDtoPath(String relativePath) {
  return relativePath.startsWith('lib/core/api/generated/') &&
      relativePath.endsWith('.models.dart');
}

bool _isGeneratedSourcePath(String relativePath) {
  return relativePath.startsWith('lib/core/api/generated/') &&
      (relativePath.endsWith('.client.dart') ||
          relativePath.endsWith('.models.dart') ||
          relativePath.endsWith('.enums.dart'));
}

String? _kindNameForPath(String relativePath) {
  const prefix = 'lib/features/library/kinds/';
  if (!relativePath.startsWith(prefix)) {
    return null;
  }
  final rest = relativePath.substring(prefix.length);
  final parts = rest.split('/');
  if (parts.isEmpty || parts.first.isEmpty || parts.first == 'registry') {
    return null;
  }
  return parts.first;
}

String? _resolveImportPath(
  String repoRoot,
  String sourceFilePath,
  String uriString,
) {
  if (uriString.startsWith('package:collectarr_app/')) {
    final packagePath = uriString.substring('package:collectarr_app/'.length);
    return p.normalize(p.join(repoRoot, 'lib', packagePath));
  }
  if (uriString.startsWith('package:') || uriString.startsWith('dart:')) {
    return null;
  }
  final sourceDir = p.dirname(sourceFilePath);
  return p.normalize(p.join(sourceDir, uriString));
}
