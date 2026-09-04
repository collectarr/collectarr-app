import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/game/data/remote/game_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/api/library_metadata_transport_codec.dart';

// ignore: avoid_unused_parameters
GameCatalogItem gameWorkFromDto(CatalogItemDto dto) =>
    GameCatalogMapper.mapMetadataItemToGame(
        LibraryMetadataTransportCodec.fromCatalogItem(dto));

// ignore: avoid_unused_parameters
GameRelease gameReleaseFromDto(CatalogEdition edition) => GameRelease(
      id: edition.id,
      title: edition.title,
      platform: edition.region,
      publisher: edition.publisher,
      barcode: edition.upc ?? edition.isbn,
      releaseDate: edition.releaseDate,
      format: edition.physicalFormatLabel ?? edition.physicalFormat,
    );

GameMedia gameMediaFromCoreDto(GameWorkDto dto) =>
    GameCoreMapper.fromWorkDto(dto);

GameRelease gameReleaseFromCoreDto(GameReleaseDto dto) =>
    GameCoreMapper.fromReleaseDto(dto);
