import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_domain.dart';

MovieWork movieWorkFromDto(MovieWorkDto dto) => MovieWork.fromDto(dto);
