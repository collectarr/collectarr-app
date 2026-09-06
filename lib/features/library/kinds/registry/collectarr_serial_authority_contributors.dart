import 'package:collectarr_app/features/catalog/serial/serial_authority_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/serial/comic_serial_authority_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/serial/manga_serial_authority_contributor.dart';

/// Composition-root registrations for kinds that expose a serial identity.
const collectarrSerialAuthorityContributors = <SerialAuthorityContributor>[
  ComicSerialAuthorityContributor(),
  MangaSerialAuthorityContributor(),
];
