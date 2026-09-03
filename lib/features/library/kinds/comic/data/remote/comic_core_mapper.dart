import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';

typedef ComicWorkDtoFetcher = Future<ComicWorkDto> Function(String id);

final class ComicCoreMapper {
  const ComicCoreMapper._();

  static ComicMedia fromWorkDto(ComicWorkDto dto) {
    if (dto.kind != null && dto.kind != 'comic') {
      throw StateError('Expected a comic Core DTO, got ${dto.kind}');
    }

    return ComicMedia(
      id: ComicMediaId(dto.id),
      title: dto.title,
      sortTitle: dto.sortTitle,
      synopsis: dto.description,
      releaseDate: dto.firstPublicationDate,
      language: dto.originalLanguage ?? 'en',
      publishing: dto.subtitle == null
          ? null
          : CatalogPublishingDetailsDto(subtitle: dto.subtitle),
      creatorCredits: _mapContributors(dto.contributors),
      releases: _mapIssues(dto.issues),
    );
  }

  static List<ComicCreatorCredit> _mapContributors(
    List<dynamic> contributors,
  ) {
    final result = <ComicCreatorCredit>[];
    for (final contributor in contributors) {
      if (contributor is Map<String, dynamic>) {
        final name = (contributor['name'] ?? contributor['display_name'])
            ?.toString()
            .trim();
        if (name == null || name.isEmpty) continue;
        result.add(
          ComicCreatorCredit(
            name: name,
            role: (contributor['role'] ?? contributor['type'] ?? 'contributor')
                .toString(),
          ),
        );
      } else {
        final name = contributor?.toString().trim();
        if (name != null && name.isNotEmpty) {
          result.add(
            ComicCreatorCredit(name: name, role: 'contributor'),
          );
        }
      }
    }
    return result;
  }

  static List<ComicRelease> _mapIssues(List<dynamic> issues) {
    return [
      for (final issue in issues)
        if (issue is Map<String, dynamic>) ComicRelease.fromJson(issue),
    ];
  }
}
