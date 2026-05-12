import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

class LibraryTypeConfig {
  const LibraryTypeConfig({
    required this.workspace,
    required this.singularLabel,
    required this.pluralLabel,
    required this.defaultMetadataProvider,
    required this.trackingProfile,
  });

  final LibraryWorkspaceConfig workspace;
  final String singularLabel;
  final String pluralLabel;
  final String defaultMetadataProvider;
  final MediaTrackingProfile trackingProfile;

  String countLabel(int count) {
    return count == 1 ? singularLabel : pluralLabel;
  }
}
