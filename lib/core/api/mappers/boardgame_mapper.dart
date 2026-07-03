import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_domain.dart';

BoardGameWork boardGameWorkFromDto(BoardGameWorkDto dto) =>
    BoardGameWork.fromDto(dto);

BoardGameEdition boardGameEditionFromDto(BoardGameEditionDto dto) =>
    BoardGameEdition.fromDto(dto);
