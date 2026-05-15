import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/library/library_home_catalog.dart';
import 'package:collectarr_app/features/library/library_home_counts.dart';
import 'package:collectarr_app/features/library/library_kind_style.dart';
import 'package:collectarr_app/features/library/library_type_registry.dart';
import 'package:flutter/material.dart';

class MediaLibraryRail extends StatelessWidget {
  const MediaLibraryRail({
    super.key,
    required this.types,
    required this.counts,
    required this.registry,
    required this.selectedKind,
    required this.onSelected,
  });

  final List<CatalogMediaType> types;
  final Map<String, LibraryKindCount> counts;
  final LibraryTypeRegistry registry;
  final String selectedKind;
  final ValueChanged<CatalogMediaType> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = selectedLibraryHomeType(types, selectedKind);
    final accent = libraryAccentForKind(selected.kind);
    return Container(
      width: 78,
      decoration: BoxDecoration(
        color: kClzToolbar,
        border: Border(right: BorderSide(color: accent)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 42,
              child: Icon(Icons.cloud_queue, color: accent, size: 22),
            ),
            const Divider(height: 1, color: kClzDivider),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: types.length,
                itemBuilder: (context, index) {
                  final type = types[index];
                  final typeAccent = libraryAccentForKind(type.kind);
                  final selected = type.kind == selectedKind;
                  return Tooltip(
                    message: type.pluralLabel,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: selected ? null : () => onSelected(type),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: selected
                                ? typeAccent.withValues(alpha: 0.34)
                                : Colors.black.withValues(alpha: 0.20),
                            border: Border.all(
                              color: selected ? Colors.white70 : typeAccent,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SizedBox(
                            height: 48,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  registry.byKind(type.kind)?.workspace.icon ??
                                      libraryIconForKind(type.kind),
                                  size: 19,
                                  color: selected ? Colors.white : typeAccent,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (counts[type.kind]?.total ?? 0).toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
