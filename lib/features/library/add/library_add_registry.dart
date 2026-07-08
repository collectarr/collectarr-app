import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_contracts.dart';

typedef LibraryAddManualKindSpecificFactory = Map<String, dynamic> Function();

class LibraryAddRegistry {
  static final Map<CatalogMediaKind, LibraryAddManualPaneBuilder> _manualBuilders = {};
  static final Map<CatalogMediaKind, LibraryAddPreviewPaneBuilder> _previewBuilders = {};
  static final Map<CatalogMediaKind, LibraryAddHeaderBuilder> _headerBuilders = {};
  static final Map<CatalogMediaKind, LibraryAddModeBarBuilder> _modeBarBuilders = {};
  static final Map<CatalogMediaKind, LibraryAddSearchPaneBuilder> _searchBuilders = {};
  static final Map<CatalogMediaKind, LibraryAddBottomBarBuilder> _bottomBuilders = {};
  static final Map<CatalogMediaKind, LibraryAddManualKindSpecificFactory> _manualKindSpecificFactories = {};

  static void registerManualBuilder(
    CatalogMediaKind kind,
    LibraryAddManualPaneBuilder builder,
  ) {
    _manualBuilders[kind] = builder;
  }

  static LibraryAddManualPaneBuilder? manualBuilderFor(CatalogMediaKind kind) {
    return _manualBuilders[kind];
  }

  static void registerPreviewBuilder(
    CatalogMediaKind kind,
    LibraryAddPreviewPaneBuilder builder,
  ) {
    _previewBuilders[kind] = builder;
  }

  static LibraryAddPreviewPaneBuilder? previewBuilderFor(CatalogMediaKind kind) {
    return _previewBuilders[kind];
  }

  static void registerHeaderBuilder(
    CatalogMediaKind kind,
    LibraryAddHeaderBuilder builder,
  ) {
    _headerBuilders[kind] = builder;
  }

  static LibraryAddHeaderBuilder? headerBuilderFor(CatalogMediaKind kind) {
    return _headerBuilders[kind];
  }

  static void registerModeBarBuilder(
    CatalogMediaKind kind,
    LibraryAddModeBarBuilder builder,
  ) {
    _modeBarBuilders[kind] = builder;
  }

  static LibraryAddModeBarBuilder? modeBarBuilderFor(CatalogMediaKind kind) {
    return _modeBarBuilders[kind];
  }

  static void registerSearchBuilder(
    CatalogMediaKind kind,
    LibraryAddSearchPaneBuilder builder,
  ) {
    _searchBuilders[kind] = builder;
  }

  static LibraryAddSearchPaneBuilder? searchBuilderFor(CatalogMediaKind kind) {
    return _searchBuilders[kind];
  }

  static void registerBottomBarBuilder(
    CatalogMediaKind kind,
    LibraryAddBottomBarBuilder builder,
  ) {
    _bottomBuilders[kind] = builder;
  }

  static void registerManualKindSpecificFactory(
    CatalogMediaKind kind,
    LibraryAddManualKindSpecificFactory factory,
  ) {
    _manualKindSpecificFactories[kind] = factory;
  }

  static LibraryAddManualKindSpecificFactory? manualKindSpecificFactoryFor(CatalogMediaKind kind) {
    return _manualKindSpecificFactories[kind];
  }

  static LibraryAddBottomBarBuilder? bottomBarBuilderFor(CatalogMediaKind kind) {
    return _bottomBuilders[kind];
  }
}
