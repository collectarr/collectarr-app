import 'package:collectarr_app/features/settings/standard_kind_settings.dart';
import 'package:collectarr_app/features/settings/kind_settings.dart';

const gameKindSettings = LibraryKindSettingsContribution(
    sections: [buildStandardKindSettings], settings: [trailerVideosSetting]);
