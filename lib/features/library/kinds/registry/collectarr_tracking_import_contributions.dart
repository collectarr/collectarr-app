import 'package:collectarr_app/features/library/kinds/tv/integrations/tmdb/tv_tracking_import_contribution.dart';

/// Composition-root registrations for semantic tracking import contributions.
///
/// Feature hosts consume the registration, while the concrete kind integration
/// remains the only place that knows how a TV season coordinate is created.
const tvTrackingImportContribution = TvTrackingImportContribution();
