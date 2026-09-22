import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:path/path.dart' as p;

import 'kind_field_ownership.dart';

void main(List<String> args) => runArchitectureChecker(args);

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
    Set<String>? kindOwnedFieldSymbols,
  }) : kindOwnedFieldSymbols =
            kindOwnedFieldSymbols ?? loadKindOwnedFieldSymbols(repoRoot);

  final String filePath;
  final String relativePath;
  final LineInfo lineInfo;
  final bool isBoundaryFile;
  final bool isRegistryFile;
  final String? kindName;
  final String repoRoot;
  final String? sourceContent;
  final Set<String> kindOwnedFieldSymbols;

  final List<String> violations = [];
  final List<String> complexityWarnings = [];
  final List<KindFieldLeakFinding> kindFieldLeaks = [];

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

  static const _neutralGenericFieldSymbols = {
    // A name alone cannot distinguish these shared record/identifier and UI
    // protocol properties from a same-named media field.
    'id',
    'kind',
    'value',
    'key',
    'apiValue',
    'api_value',
    'entityType',
    'entity_type',
    'rootId',
    'root_id',
    'parentId',
    'parent_id',
    'targetId',
    'target_id',
    'ownedRef',
    'owned_ref',
    'ownedRefKey',
    'owned_ref_key',
    'trackingEntryId',
    'tracking_entry_id',
    'source',
    'sourceType',
    'source_type',
    'color',
    'network',
    'format',
    'currency',
    'url',
    'location',
    'title',
    'sortTitle',
    'sort_title',
    'label',
    'primaryLabel',
    'primary_label',
    'subtitle',
    'summary',
    'description',
    'imageUrl',
    'image_url',
    'coverImageUrl',
    'cover_image_url',
    'createdAt',
    'created_at',
    'updatedAt',
    'updated_at',
    'deletedAt',
    'deleted_at',
  };

  static const _forbiddenRuntimeTypeNames = {
    'CatalogItemDto',
    'LibraryKindMetadataRuntime',
    'LibraryMetadataItem',
    'LibraryCatalogItemView',
  };

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (_isStrictGenericContext(relativePath)) {
      final propertyName = node.propertyName.name;
      final isFlutterThemePlatform = propertyName == 'platform' &&
          node.target?.toSource().startsWith('Theme.of(') == true;
      if (!isFlutterThemePlatform) {
        _checkInferredFieldLeak(
          propertyName,
          node.offset,
          'member-access',
          skipKnownPolicyMember: true,
        );
      }
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
      _checkInferredFieldLeak(
        methodName,
        node.offset,
        'member-access',
        skipKnownPolicyMember: true,
      );
      if (_forbiddenContextualMemberNames.contains(methodName)) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          'TK010 $relativePath:$line: Forbidden contextual semantic method/getter call "$methodName" in generic library code',
        );
      }
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    if (_isStrictGenericContext(relativePath)) {
      final key = _stringLiteralValue(node.index);
      if (key != null) {
        _checkInferredFieldLeak(key, node.offset, 'map-index');
      }
    }
    super.visitIndexExpression(node);
  }

  @override
  void visitMapLiteralEntry(MapLiteralEntry node) {
    if (_isStrictGenericContext(relativePath)) {
      final key = _stringLiteralValue(node.key);
      if (key != null) {
        _checkInferredFieldLeak(key, node.offset, 'map-key');
      }
    }
    super.visitMapLiteralEntry(node);
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
    final lineNumber = lineInfo.getLocation(offset).lineNumber;
    final importedPath = _resolveImportPath(repoRoot, filePath, uriString);
    if (importedPath == null) return;

    final importedRelativePath =
        p.relative(importedPath, from: repoRoot).replaceAll('\\', '/');

    if (isRegistryFile || _compositionRoots.contains(relativePath)) {
      if (importedRelativePath.startsWith('lib/features/library/kinds/') &&
          !importedRelativePath
              .startsWith('lib/features/library/kinds/registry/') &&
          !_isKindModulePath(importedRelativePath)) {
        violations.add(
          'TK011 $relativePath:$lineNumber: Kind registries may import only the public kind module ($uriString)',
        );
      }
      return;
    }

    if (!_compositionRoots.contains(relativePath) &&
        _isProviderPath(relativePath) &&
        importedRelativePath.startsWith('lib/features/library/kinds/')) {
      violations.add(
        'TK007 $relativePath:$lineNumber: Provider code must not import kind-specific modules ($uriString)',
      );
      return;
    }

    if (_isGeneratedCoreDtoPath(importedRelativePath) &&
        !_isGeneratedDtoImportBoundary(relativePath, kindName)) {
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

    if (_isGenericMetadataMap(node)) {
      final line = lineInfo.getLocation(node.offset).lineNumber;
      violations.add(
        'TK003 $relativePath:$line: Generic metadata map must be classified or moved to a kind-owned mapper',
      );
    }

    if (_isDynamicCatalogType(node)) {
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
    if (isBoundaryFile && !_isStructuralSwitchFile(relativePath)) {
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
    if (isBoundaryFile && !_isStructuralSwitchFile(relativePath)) {
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
        !_isStructuralComparisonFile(relativePath) &&
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
        _isStructuralProjectionFile(relativePath)) {
      return;
    }
    _checkInferredFieldLeak(
      name,
      offset,
      'member-declaration',
      skipKnownPolicyMember: true,
    );
    if (!_forbiddenContextualMemberNames.contains(name)) return;
    final line = lineInfo.getLocation(offset).lineNumber;
    violations.add(
      'TK010 $relativePath:$line: Forbidden contextual semantic declaration "$name" in generic library code',
    );
  }

  void _checkInferredFieldLeak(
    String symbol,
    int offset,
    String surface, {
    bool skipKnownPolicyMember = false,
  }) {
    if (!_isInferredFieldLeakContext(relativePath) ||
        _neutralGenericFieldSymbols.contains(symbol) ||
        !kindOwnedFieldSymbols.contains(symbol) ||
        (skipKnownPolicyMember &&
            _forbiddenContextualMemberNames.contains(symbol))) {
      return;
    }
    final line = lineInfo.getLocation(offset).lineNumber;
    final message = 'TK016 $relativePath:$line: Kind-owned field "$symbol" '
        'appears in generic code ($surface)';
    violations.add(message);
    kindFieldLeaks.add(KindFieldLeakFinding(
      relativePath: relativePath,
      symbol: symbol,
      surface: surface,
      message: message,
    ));
  }

  String? _stringLiteralValue(Expression? expression) {
    if (expression is StringLiteral) return expression.stringValue;
    return null;
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
    if (keyType != 'String' || valueType != 'dynamic') {
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

bool _isInferredFieldLeakContext(String relativePath) {
  if (relativePath.startsWith('lib/features/library/') &&
      !relativePath.startsWith('lib/features/library/kinds/')) {
    return true;
  }
  if (relativePath.startsWith('lib/features/catalog/') &&
      !relativePath.startsWith('lib/features/catalog/transport/')) {
    return true;
  }
  if (relativePath.startsWith('lib/core/api/mappers/')) return true;
  if (!relativePath.startsWith('lib/core/models/')) return false;

  final fileName = p.basename(relativePath);
  return fileName.startsWith('catalog_') ||
      fileName.startsWith('library_') ||
      fileName.startsWith('owned_') ||
      fileName.startsWith('tracking_') ||
      fileName.startsWith('personal_tracking_') ||
      fileName == 'activity_event.dart' ||
      fileName == 'calendar_event.dart';
}

bool _isGeneratedDtoImportBoundary(String relativePath, String? kindName) {
  return relativePath == 'lib/core/api/api_client.dart' ||
      relativePath.startsWith('lib/core/api/generated/') ||
      relativePath.startsWith('lib/features/catalog/transport/') ||
      relativePath.startsWith('lib/features/providers/') ||
      kindName != null;
}

bool _isStructuralProjectionFile(String relativePath) {
  return const {
    'lib/core/models/catalog_display_summary.dart',
    'lib/core/models/catalog_search_hit.dart',
    'lib/core/models/calendar_event.dart',
    'lib/core/models/owned_item_projection.dart',
  }.contains(relativePath);
}

bool _isStructuralSwitchFile(String relativePath) {
  return const {
    'lib/core/models/activity_event.dart',
    'lib/core/models/calendar_event.dart',
  }.contains(relativePath);
}

bool _isStructuralComparisonFile(String relativePath) {
  return const {
    'lib/core/models/catalog_media_kind.dart',
    'lib/features/collection/csv/collection_csv_codec.dart',
    'lib/features/collection/mutations/wishlist_mutations.dart',
    'lib/features/imports/personal_lists/anime_list_import_service.dart',
    'lib/features/library/selection/library_bulk_actions.dart',
  }.contains(relativePath);
}

const _registryRoot = 'lib/features/library/kinds/registry/';
const _kindFieldLeakBaselinePath =
    'tool/architecture/kind-field-leak-baseline.json';

class KindFieldLeakFinding {
  const KindFieldLeakFinding({
    required this.relativePath,
    required this.symbol,
    required this.surface,
    required this.message,
  });

  final String relativePath;
  final String symbol;
  final String surface;
  final String message;

  String get key => '$relativePath|$surface|$symbol';

  Map<String, String> toJson() => <String, String>{
        'path': relativePath,
        'surface': surface,
        'symbol': symbol,
      };
}

void runArchitectureChecker([List<String> args = const <String>[]]) {
  final repoRoot = Directory.current.path;
  final libRoot = p.join(repoRoot, 'lib');
  final files = _dartFilesUnder(Directory(libRoot)).toList()..sort();

  final allViolations = <String>[];
  final allComplexityWarnings = <String>[];
  final allKindFieldLeaks = <KindFieldLeakFinding>[];

  _checkKindModuleLayout(repoRoot, allViolations);

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
    allViolations.addAll(
      visitor.violations.where((violation) => !violation.startsWith('TK016 ')),
    );
    allKindFieldLeaks.addAll(visitor.kindFieldLeaks);
    allComplexityWarnings.addAll(visitor.complexityWarnings);
  }

  final updateFieldBaseline =
      args.contains('--update-kind-field-leak-baseline');
  final baselineFile = File(p.joinAll([
    repoRoot,
    ..._kindFieldLeakBaselinePath.split('/'),
  ]));
  final currentFindingsByKey = <String, KindFieldLeakFinding>{
    for (final finding in allKindFieldLeaks) finding.key: finding,
  };
  final baselineKeys = <String>{};
  if (updateFieldBaseline) {
    final entries = currentFindingsByKey.values.toList()
      ..sort((left, right) => left.key.compareTo(right.key));
    baselineFile.parent.createSync(recursive: true);
    final baselineJson = const JsonEncoder.withIndent('  ').convert(
      <String, Object?>{
        'formatVersion': 1,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      },
    );
    baselineFile.writeAsStringSync('$baselineJson\n');
    baselineKeys.addAll(currentFindingsByKey.keys);
    stdout.writeln(
      'Updated exact kind-field leak baseline '
      '(${baselineKeys.length} path/surface/symbol entries).',
    );
  } else {
    baselineKeys.addAll(_loadKindFieldLeakBaseline(baselineFile).keys);
  }

  for (final finding in currentFindingsByKey.values) {
    if (!baselineKeys.contains(finding.key)) {
      allViolations.add(finding.message);
    }
  }
  if (!updateFieldBaseline) {
    final observedKeys = currentFindingsByKey.keys.toSet();
    for (final staleKey in baselineKeys.difference(observedKeys).toList()
      ..sort()) {
      allViolations.add(
        'TK017 $_kindFieldLeakBaselinePath: Stale exact field-leak baseline '
        'entry "$staleKey"; remove it after the leak is fixed.',
      );
    }
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

Map<String, KindFieldLeakFinding> _loadKindFieldLeakBaseline(File file) {
  if (!file.existsSync()) return const <String, KindFieldLeakFinding>{};
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic> || decoded['entries'] is! List) {
    throw FormatException('Invalid kind field leak baseline: ${file.path}');
  }
  final entries = <String, KindFieldLeakFinding>{};
  for (final entry in decoded['entries'] as List) {
    if (entry is! Map) {
      throw FormatException('Invalid baseline entry in ${file.path}');
    }
    final path = entry['path'];
    final surface = entry['surface'];
    final symbol = entry['symbol'];
    if (path is! String || surface is! String || symbol is! String) {
      throw FormatException('Invalid baseline entry in ${file.path}');
    }
    final finding = KindFieldLeakFinding(
      relativePath: path,
      surface: surface,
      symbol: symbol,
      message: '',
    );
    if (entries.containsKey(finding.key)) {
      throw FormatException('Duplicate baseline key "${finding.key}"');
    }
    entries[finding.key] = finding;
  }
  return entries;
}

void _checkKindModuleLayout(String repoRoot, List<String> violations) {
  final kindsRoot = Directory(
    p.join(repoRoot, 'lib', 'features', 'library', 'kinds'),
  );
  if (!kindsRoot.existsSync()) return;

  for (final entity in kindsRoot.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final relativePath = p.relative(entity.path, from: repoRoot).replaceAll(
          '\\',
          '/',
        );
    final content = entity.readAsStringSync();
    if (p.basename(entity.path).contains('_kind_components')) {
      violations.add(
        'TK012 $relativePath: Legacy kind component files are forbidden; '
        'expose the contribution through the kind module libraries.',
      );
    }
    if (RegExp(r'^\s*part(?:\s+of)?\s+', multiLine: true).hasMatch(content)) {
      violations.add(
        'TK013 $relativePath: Kind modules must be independent libraries; '
        '`part` files are forbidden under library/kinds.',
      );
    }
  }

  final workspaceSchema = File(
    p.join(
      repoRoot,
      'lib',
      'features',
      'library',
      'workspace',
      'schema',
      'library_entity_workspace_schema.dart',
    ),
  );
  if (workspaceSchema.existsSync() &&
      workspaceSchema.readAsStringSync().contains('.withEntityScope(')) {
    violations.add(
      'TK014 lib/features/library/workspace/schema/'
      'library_entity_workspace_schema.dart: Scoped field definitions must '
      'not be silently rebound to another entity scope.',
    );
  }

  const sharedSemanticUiFiles = {
    'lib/features/library/workspace/tiles/library_workspace_card.dart',
    'lib/features/library/workspace/tiles/library_card_flow_tile.dart',
    'lib/features/library/workspace/layout/library_flow_carousel.dart',
    'lib/features/library/detail/library_title_metadata_section.dart',
  };
  for (final relativePath in sharedSemanticUiFiles) {
    final file =
        File(p.join(repoRoot, relativePath.replaceAll('/', p.separator)));
    if (!file.existsSync()) continue;
    final content = file.readAsStringSync();
    final forbidden = <String>[
      "'Publisher'",
      "'Studio'",
      "'Label'",
      "'Developer'",
      "'Runtime'",
      "'Tracks'",
      "'Release Status'",
      '_metadataFactValue(',
    ];
    for (final token in forbidden) {
      if (content.contains(token)) {
        violations.add(
          'TK015 $relativePath: Shared presentation must consume '
          'kind-resolved descriptors, not semantic label lookup ($token).',
        );
      }
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
  'lib/features/activity/library_activity_registry.dart',
  'lib/features/admin/library_admin_registry.dart',
  'lib/features/barcode/library_barcode_registry.dart',
  'lib/features/calendar/library_calendar_registry.dart',
  'lib/features/catalog/library_catalog_registry.dart',
  'lib/features/collection/collection_kind_contributors.dart',
  'lib/features/collection/csv/collection_csv_registry.dart',
  'lib/features/library/tracking/library_tracking_registry.dart',
  'lib/features/library/library_kind_registry.dart',
  'lib/features/library/owned/owned_kind_contributor_registry.dart',
  'lib/features/providers/library_provider_registry.dart',
};

bool _isKindModulePath(String relativePath) {
  final parts = relativePath.split('/');
  if (parts.length != 6 ||
      parts[0] != 'lib' ||
      parts[1] != 'features' ||
      parts[2] != 'library' ||
      parts[3] != 'kinds') {
    return false;
  }
  final kind = parts[4];
  return parts[5] == '${kind}_module.dart';
}

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
