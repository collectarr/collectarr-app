import 'package:collectarr_app/core/api/generated/catalog_typed_dtos.dart';
import 'package:collectarr_app/features/library/kinds/game/game_domain.dart';

GameWork gameWorkFromDto(GameWorkDto dto) => GameWork.fromDto(dto);

GameRelease gameReleaseFromDto(GameReleaseDto dto) => GameRelease.fromDto(dto);
