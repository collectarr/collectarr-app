part of 'video_edit_tabs.dart';

class VideoEditLinksTab extends ConsumerWidget {
  const VideoEditLinksTab({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    required this.videoEdit,
  });

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final Color accent;
  final VideoEditController videoEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerLinks = item.trailerUrls;
    return EditTabShell(
      children: [
        if (providerLinks.isNotEmpty)
          EditSection(
            title: 'Provider links',
            accent: accent,
            child: VideoExternalLinksSection(
              title: 'Provider links',
              links: providerLinks,
              accent: accent,
            ),
          ),
        EditSection(
          title: 'User links',
          accent: accent,
          child: LibraryExternalLinksEditor(
            title: 'User links',
            items: videoEdit.userLinkEdits,
            onAdd: () => videoEdit.userLinkEdits.add(
              EditableUserExternalLink.fromTrailerLink(
                TrailerLink(
                  url: '',
                  source: 'manual',
                  isAutomatic: false,
                  kind: 'external',
                ),
                kind: 'custom',
              ),
            ),
          ),
        ),
        EditSection(
          title: 'Trailers',
          accent: accent,
          child: LibraryExternalLinksEditor(
            title: 'Trailers',
            items: videoEdit.userTrailerEdits,
            onAdd: () => videoEdit.userTrailerEdits.add(
              EditableUserExternalLink.fromTrailerLink(
                TrailerLink(
                  url: '',
                  source: 'manual',
                  isAutomatic: false,
                  kind: 'trailer',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
