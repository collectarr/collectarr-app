import 'package:collectarr_app/core/api/generated/catalog_typed_dtos.dart';
import 'package:collectarr_app/features/library/kinds/book/book_domain.dart';

BookWork bookWorkFromDto(BookWorkDto dto) => BookWork.fromDto(dto);

BookEdition bookEditionFromDto(BookEditionDto dto) => BookEdition.fromDto(dto);
