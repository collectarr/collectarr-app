import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/partial_date.dart';

String formatMusicCell(Object? value) => switch (value) {
      null => '',
      bool v => v ? 'Yes' : 'No',
      Iterable<Object?> v => v.map(formatMusicCell).join(' | '),
      PartialDate v => AppFormats.current.formatPartialDate(v),
      DateTime v => AppFormats.current.formatDate(v),
      _ => value.toString(),
    };
