import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:path/path.dart' as p;

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
    // Movie & Video
    'MovieCatalogMetadata',
    'MovieMetadata',
    'MovieWorkspaceDto',
    'MovieCatalogItem',
    'MovieOwnedDetails',
    // Tv
    'TvCatalogMetadata',
    'TvMetadata',
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
    'BookMetadata',
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
    'GameMetadata',
    'GameWorkspaceDto',
    'GameCatalogItem',
    'GameOwnedDetails',
    // BoardGame
    'BoardGameCatalogMetadata',
    'BoardGameMetadata',
    'BoardGameWorkspaceDto',
    'BoardGameCatalogItem',
    'BoardGameOwnedDetails',
    // Music
    'MusicCatalogMetadata',
    'MusicMetadata',
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
    'subtitle',
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

  static const _genericMetadataMapAllowlist = {
    'lib/features/library/add/controllers/library_add_comparisons.dart',
    'lib/features/library/add/panes/library_add_preview_pane.dart',
    'lib/features/library/add/services/library_add_workflow_service.dart',
    'lib/features/library/add/services/library_provider_orchestration_service.dart',
    'lib/features/library/add/services/provider_add_result_merge.dart',
    'lib/features/library/config/generic_library_media_presentation.dart',
    'lib/features/library/config/library_entry_helpers.dart',
    'lib/features/library/config/library_group_bucket_mutation.dart',
    'lib/features/library/config/library_page_utilities.dart',
    'lib/features/library/config/owned_details_codec.dart',
    'lib/features/library/config/presentation/library_metadata_presentation.dart',
    'lib/features/library/edit/draft/library_edit_draft.dart',
    'lib/features/library/generic/library_sort_preset_store.dart',
    'lib/features/library/generic/page/coordinators/page_cover_coordinator.dart',
    'lib/features/library/metadata/library_metadata_compare_dialog.dart',
    'lib/features/library/metadata/library_metadata_proposal.dart',
    'lib/features/library/metadata/library_metadata_widgets.dart',
    'lib/features/library/metadata/metadata_proposal_store.dart',
    'lib/features/library/metadata/provider_candidate.dart',
  };

  static const _dynamicCatalogAllowlist = {
    'lib/features/catalog/catalog_cache_repository.dart',
    'lib/features/collection/csv/collection_csv.dart',
    'lib/features/collection/mutations/collection_import_service.dart',
    'lib/features/collection/mutations/owned_item_mutations.dart',
    'lib/features/collection/mutations/tracking_mutations.dart',
    'lib/features/collection/mutations/wishlist_mutations.dart',
    'lib/features/collection/repositories/custom_field_repository.dart',
    'lib/features/collection/repositories/shelf_controller.dart',
    'lib/features/library/add/controllers/library_add_comparisons.dart',
    'lib/features/library/add/library_add_collection_workflow.dart',
    'lib/features/library/api/library_metadata_transport_codec.dart',
    'lib/features/library/add/services/library_add_workflow_service.dart',
    'lib/features/library/config/library_entry_helpers.dart',
    'lib/features/library/config/library_group_bucket_mutation.dart',
    'lib/features/library/detail/library_detail_hero.dart',
    'lib/features/library/detail/story_arc_detail_page.dart',
    'lib/features/library/generic/library_route_state.dart',
    'lib/features/library/hierarchy/domain/library_hierarchy_node.dart',
    'lib/features/library/inspector/metadata_correction_dialog.dart',
    'lib/features/library/inspector/sections/contributors_section.dart',
    'lib/features/library/kinds/_shared/serial/authority/serial_authority_repository.dart',
    'lib/features/library/kinds/_shared/serial/serial_library_media_presentation_builder.dart',
    'lib/features/library/kinds/_shared/video/detail/video_inspector_sections.dart',
    'lib/features/library/kinds/_shared/video/domain/video_episode.dart',
    'lib/features/library/kinds/_shared/video/edit/tabs/video_edit_models.dart',
    'lib/features/library/kinds/_shared/video/release/video_release_source.dart',
    'lib/features/library/kinds/anime/domain/anime_metadata.dart',
    'lib/features/library/kinds/boardgame/domain/boardgame_metadata.dart',
    'lib/features/library/kinds/boardgame/presentation_builder.dart',
    'lib/features/library/kinds/book/catalog/book_catalog_mapper.dart',
    'lib/features/library/kinds/boardgame/catalog/boardgame_catalog_mapper.dart',
    'lib/features/library/kinds/book/domain/book_metadata.dart',
    'lib/features/library/kinds/book/presentation_builder.dart',
    'lib/features/library/kinds/comic/detail/comic_series_detail_page.dart',
    'lib/features/library/kinds/comic/edit/comic_edit_models.dart',
    'lib/features/library/kinds/comic/inspector_sections.dart',
    'lib/features/library/kinds/game/catalog/game_catalog_mapper.dart',
    'lib/features/library/kinds/game/presentation_builder.dart',
    'lib/features/library/kinds/manga/domain/manga_metadata.dart',
    'lib/features/library/kinds/manga/presentation_builder.dart',
    'lib/features/library/kinds/movie/domain/movie_metadata.dart',
    'lib/features/library/kinds/movie/inspector_sections.dart',
    'lib/features/library/kinds/movie/presentation_builder.dart',
    'lib/features/library/kinds/music/catalog/music_catalog_mapper.dart',
    'lib/features/library/kinds/music/domain/music_metadata.dart',
    'lib/features/library/kinds/music/edit_dialog.dart',
    'lib/features/library/kinds/music/presentation_builder.dart',
    'lib/features/library/kinds/music/workspace/music_card_presentation.dart',
    'lib/features/library/kinds/tv/domain/tv_metadata.dart',
    'lib/features/library/kinds/tv/inspector_sections.dart',
    'lib/features/library/kinds/boardgame/edit/release/boardgame_release_edit_dialog.dart',
    'lib/features/library/metadata/library_metadata_compare_dialog.dart',
    'lib/features/library/metadata/library_metadata_proposal.dart',
    'lib/features/library/metadata/metadata_proposal_store.dart',
    'lib/features/library/models/library_catalog_item_view.dart',
    'lib/features/library/models/library_entry.dart',
    'lib/features/library/models/library_kind_metadata_values.dart',
    'lib/features/library/models/library_metadata_item.dart',
    'lib/features/library/workspace/data/library_workspace_repository.dart',
    'lib/features/library/workspace/layout/library_flow_carousel.dart',
    'lib/features/library/workspace/tiles/library_workspace_card.dart',
    'lib/features/providers/domain/mappers/provider_preview_mapper.dart',
  };

  static const _generatedDtoAllowlist = {
    // Generated protocol clients and their direct HTTP facade are transport
    // boundaries. They are not application kind mappers.
    'lib/core/api/api_client.dart',
    'lib/core/api/api_client_admin.dart',
    'lib/core/api/generated/collectarr_api.client.dart',
    'lib/features/library/kinds/comic/data/remote/comic_core_mapper.dart',
    'lib/features/library/kinds/manga/data/remote/manga_core_mapper.dart',
    'lib/features/library/kinds/book/data/remote/book_core_mapper.dart',
    'lib/features/library/kinds/game/data/remote/game_core_mapper.dart',
    'lib/features/library/kinds/boardgame/data/remote/boardgame_core_mapper.dart',
    'lib/features/library/kinds/movie/data/remote/movie_core_mapper.dart',
    'lib/features/library/kinds/anime/data/remote/anime_core_mapper.dart',
    'lib/features/library/kinds/music/data/remote/music_core_mapper.dart',
    'lib/features/library/kinds/tv/data/remote/tv_core_mapper.dart',
    'lib/features/library/kinds/tv/data/remote/tv_remote_source.dart',
    'lib/features/library/kinds/_shared/video/providers/video_seasons_provider.dart',
  };

  static const _structuralProjectionAllowlist = {
    'lib/core/models/owned_item_projection.dart',
  };

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (_isStrictGenericContext(relativePath)) {
      final propertyName = node.propertyName.name;
      if (_forbiddenContextualMemberNames.contains(propertyName)) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          '$relativePath:$line: Forbidden contextual semantic member access "$propertyName" in generic library code',
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
          '$relativePath:$line: Forbidden contextual semantic method/getter call "$methodName" in generic library code',
        );
      }
    }
    super.visitMethodInvocation(node);
  }

  bool _isStrictGenericContext(String path) {
    if (path.startsWith('lib/features/library/kinds/') ||
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
        '$relativePath:$lineNumber: Provider code must not import kind-specific modules ($uriString)',
      );
      return;
    }

    if (_isGeneratedCoreDtoPath(importedRelativePath) &&
        !_generatedDtoAllowlist.contains(relativePath)) {
      violations.add(
        '$relativePath:$lineNumber: Generated Core DTO import must stay inside the owning kind module ($uriString)',
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
        '$relativePath:$lineNumber: Forbidden import of kind-specific module ($uriString) from generic boundary code',
      );
      return;
    }

    if (kindName != null) {
      final importedKind = _kindNameForPath(importedRelativePath);
      if (importedKind != null &&
          importedKind != kindName &&
          !isAllowedKindImport(kindName!, importedKind)) {
        violations.add(
          '$relativePath:$lineNumber: Cross-kind import violation ($directive $uriString)',
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
        '$relativePath:$line: Legacy erased runtime type "${node.name.lexeme}" must stay out of feature layers',
      );
    }

    if (_isGenericMetadataMap(node) &&
        !_genericMetadataMapAllowlist.contains(relativePath)) {
      final line = lineInfo.getLocation(node.offset).lineNumber;
      violations.add(
        '$relativePath:$line: Generic metadata map must be classified or moved to a kind-owned mapper',
      );
    }

    if (_isDynamicCatalogType(node) &&
        !_dynamicCatalogAllowlist.contains(relativePath)) {
      final line = lineInfo.getLocation(node.offset).lineNumber;
      violations.add(
        '$relativePath:$line: Dynamic catalog/metadata object must be replaced or explicitly allowlisted',
      );
    }

    if (isBoundaryFile) {
      final typeName = node.name.lexeme;
      if (_forbiddenKindDomainTypes.contains(typeName)) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          '$relativePath:$line: Forbidden concrete kind domain type "$typeName" in generic boundary code',
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
            '$relativePath:$line: Forbidden dynamic field registry "LibraryFieldRegistry<dynamic>" in generic boundary code',
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
            '$relativePath:$line: Forbidden concrete kind reference "$idName" in generic boundary code',
          );
        }
      }
    }
    super.visitSimpleIdentifier(node);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    if (isBoundaryFile) {
      final expr = node.expression.toSource();
      if (expr.contains('kind') || expr.contains('CatalogMediaKind')) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          '$relativePath:$line: Forbidden CatalogMediaKind switch statement in generic boundary code',
        );
      }
    }
    super.visitSwitchStatement(node);
  }

  @override
  void visitSwitchExpression(SwitchExpression node) {
    if (isBoundaryFile) {
      final expr = node.expression.toSource();
      if (expr.contains('kind') || expr.contains('CatalogMediaKind')) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          '$relativePath:$line: Forbidden CatalogMediaKind switch expression in generic boundary code',
        );
      }
    }
    super.visitSwitchExpression(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (isBoundaryFile &&
        (node.operator.lexeme == '==' || node.operator.lexeme == '!=')) {
      final left = node.leftOperand.toSource();
      final right = node.rightOperand.toSource();
      if ((left.contains('kind') && right.contains('CatalogMediaKind.')) ||
          (right.contains('kind') && left.contains('CatalogMediaKind.'))) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          '$relativePath:$line: Forbidden CatalogMediaKind comparison in generic boundary code',
        );
      }
    }
    super.visitBinaryExpression(node);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final startLine = lineInfo.getLocation(node.offset).lineNumber;
    final endLine = lineInfo.getLocation(node.end).lineNumber;
    final classLength = endLine - startLine + 1;
    final className = node.namePart.toSource();
    if (classLength > 500 && !_isExempt(relativePath)) {
      complexityWarnings.add(
        '$relativePath:$startLine: Class "$className" exceeds complexity budget ($classLength > 500 lines)',
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
        '$relativePath:$startLine: Method "${node.name.lexeme}" exceeds complexity budget ($methodLength > 100 lines)',
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
      '$relativePath:$line: Forbidden contextual semantic declaration "$name" in generic library code',
    );
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final startLine = lineInfo.getLocation(node.offset).lineNumber;
    final endLine = lineInfo.getLocation(node.end).lineNumber;
    final funcLength = endLine - startLine + 1;
    if (funcLength > 100 && !_isExempt(relativePath)) {
      complexityWarnings.add(
        '$relativePath:$startLine: Function "${node.name.lexeme}" exceeds complexity budget ($funcLength > 100 lines)',
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
        '$relativePath:$line: Callable "$callableName" exceeds parameter budget (${parameters.parameters.length} > 18 params)',
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
            !path.startsWith('lib/features/providers/') ||
        path.startsWith('lib/core/models/') ||
        path.startsWith('lib/core/api/mappers/') ||
        path.startsWith('lib/core/routing/') ||
        path.startsWith('lib/core/settings/');
  }
}

const _registryRoot = 'lib/features/library/kinds/registry/';

void main(List<String> arguments) {
  final repoRoot = Directory.current.path;
  final libRoot = p.join(repoRoot, 'lib');
  final files = _dartFilesUnder(Directory(libRoot)).toList()..sort();

  final allViolations = <String>[];
  final allComplexityWarnings = <String>[];

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
        '$relativePath: File exceeds complexity budget ($lineCount > 800 lines)',
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
  if (parts.isEmpty ||
      parts.first.isEmpty ||
      parts.first == 'registry' ||
      parts.first == '_shared') {
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
