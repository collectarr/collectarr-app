import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_facts.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

abstract interface class MusicWorkspaceProjection
    implements LibraryWorkspaceDto {
  WorkspaceCommonProjection get common;
  PersonalEntryProjection get personal;
  MusicAlbum get music;
  MusicWorkspaceFacts get facts;
  MusicEntryListeningSummary? get listeningSummary;
}

abstract class MusicWorkspaceProjectionValues
    implements MusicWorkspaceProjection {
  MusicWorkspaceProjectionValues({
    required this.common,
    required this.personal,
    required this.music,
    required this.facts,
    this.listeningSummary,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalEntryProjection personal;
  @override
  final MusicAlbum music;
  @override
  final MusicWorkspaceFacts facts;
  @override
  final MusicEntryListeningSummary? listeningSummary;

  String get title => common.title;

  @override
  String get primaryLabel => title;

  @override
  String? get imageUrl => common.coverImageUrl;

  @override
  String? get secondaryLabel => null;
}

final class MusicCatalogItemWorkspaceDto
    extends MusicWorkspaceProjectionValues {
  MusicCatalogItemWorkspaceDto({
    required super.common,
    required super.personal,
    required super.music,
    required super.facts,
    super.listeningSummary,
  });
}

final class MusicLibraryEntryWorkspaceDto
    extends MusicWorkspaceProjectionValues {
  MusicLibraryEntryWorkspaceDto({
    required super.common,
    required super.personal,
    required super.music,
    required super.facts,
    super.listeningSummary,
  });
}
