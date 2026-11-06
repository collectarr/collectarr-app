import 'package:collectarr_app/features/library/workspace/layout/bucket_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:collectarr_app/features/library/workspace/schema/group_values.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/workspace/config/tokens.dart';
import 'package:flutter/material.dart';

/// Folder list shown before entering a native mobile library bucket.
class LibraryMobileFolderChooser extends StatefulWidget {
  const LibraryMobileFolderChooser({
    super.key,
    required this.buckets,
    required this.folderLabel,
    required this.allBucketLabel,
    required this.onSelected,
  });

  final List<LibraryBucket> buckets;
  final String folderLabel;
  final String allBucketLabel;
  final ValueChanged<String> onSelected;

  @override
  State<LibraryMobileFolderChooser> createState() =>
      _LibraryMobileFolderChooserState();
}

/// The folder's item cover, as in the reference, or a folder icon without one.
class _FolderImage extends StatelessWidget {
  const _FolderImage({required this.bucket});

  final LibraryBucket bucket;

  @override
  Widget build(BuildContext context) => SizedBox(
      width: 34,
      height: 50,
      child: bucket.coverUrl == null && bucket.coverEntryRef == null
          ? const Icon(Icons.folder_outlined)
          : LibraryCoverImage(
              title: bucket.title,
              imageUrl: bucket.coverUrl,
              libraryEntryRef: bucket.coverEntryRef,
              targetCacheWidth: 68,
              fallbackAspectRatio: 34 / 50,
              fit: BoxFit.cover,
              borderRadius: 0,
              showPlaceholder: false,
            ));
}

class _LibraryMobileFolderChooserState
    extends State<LibraryMobileFolderChooser> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final buckets = widget.buckets
        .where((bucket) =>
            bucket.title.toLowerCase().contains(query.trim().toLowerCase()))
        .toList();
    final namedCount = buckets
        .where((bucket) =>
            bucket.title != widget.allBucketLabel &&
            bucket.title != libraryEmptyGroupLabel)
        .length;
    final label = widget.folderLabel.toLowerCase();
    final countLabel =
        namedCount == 1 || label.endsWith('s') ? label : '${label}s';
    final searchLabel = label.endsWith('s') ? label : '${label}s';
    return Material(
      color: libraryWorkspaceBackgroundColor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              key: const Key('library.mobile-folder-search'),
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search $searchLabel...',
                isDense: true,
                filled: false,
                fillColor: Colors.transparent,
                border: const UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: palette.divider)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              '$namedCount $countLabel',
              style: TextStyle(color: palette.textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: ListView.separated(
              key: const Key('library.mobile-folder-list'),
              itemCount: buckets.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final bucket = buckets[index];
                return ListTile(
                  key: Key('library.mobile-folder-${bucket.title}'),
                  leading: _FolderImage(bucket: bucket),
                  title: Text(bucket.title),
                  trailing: Container(
                    constraints:
                        const BoxConstraints(minWidth: 24, minHeight: 24),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: palette.textMuted.withValues(alpha: .65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${bucket.count}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                  onTap: () => widget.onSelected(bucket.title),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
