import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';

final class AdminCatalogSearchPanel extends StatelessWidget {
  const AdminCatalogSearchPanel({
    required this.queryController,
    required this.kind,
    required this.kinds,
    required this.kindLabels,
    required this.isLoadingKinds,
    required this.isSearching,
    required this.statusMessage,
    required this.errorMessage,
    required this.onKindChanged,
    required this.onSearch,
    required this.results,
    super.key,
  });

  final TextEditingController queryController;
  final String? kind;
  final List<String> kinds;
  final Map<String, String> kindLabels;
  final bool isLoadingKinds;
  final bool isSearching;
  final String? statusMessage;
  final String? errorMessage;
  final ValueChanged<String?> onKindChanged;
  final VoidCallback onSearch;
  final Widget results;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
    );
    Widget kindField() {
      return CompactSearchDropdownFormField<String>(
        initialValue: kind != null && kinds.contains(kind) ? kind : '',
        isExpanded: true,
        dropdownColor: appPalette(context).panelRaised,
        borderRadius: kAppMenuBorderRadius,
        decoration: InputDecoration(
          labelText: 'Media kind',
          border: border,
        ),
        items: [
          const DropdownMenuItem(value: '', child: Text('All kinds')),
          for (final option in kinds)
            DropdownMenuItem(
              value: option,
              child: Text(kindLabels[option] ?? option),
            ),
        ],
        onChanged: isLoadingKinds
            ? null
            : (value) => onKindChanged(value?.isEmpty == true ? null : value),
      );
    }

    Widget searchButton() => FilledButton.icon(
          onPressed: isSearching ? null : onSearch,
          icon: isSearching
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search),
          label: const Text('Search'),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Catalog search',
                      style: theme.textTheme.titleMedium),
                ),
                IconButton(
                  tooltip: 'Search catalog',
                  onPressed: isSearching ? null : onSearch,
                  icon: isSearching
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final queryField = TextField(
                  controller: queryController,
                  decoration: InputDecoration(
                    labelText: 'Find catalog items',
                    hintText: 'Search by title, number, or provider ID',
                    prefixIcon: const Icon(Icons.manage_search_outlined),
                    border: border,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => onSearch(),
                );
                if (constraints.maxWidth < 640) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      kindField(),
                      const SizedBox(height: 12),
                      queryField,
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: searchButton(),
                      ),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 180, child: kindField()),
                    const SizedBox(width: 12),
                    Expanded(child: queryField),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: searchButton(),
                    ),
                  ],
                );
              },
            ),
            if (statusMessage != null || errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage ?? statusMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: errorMessage == null
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 12),
            results,
          ],
        ),
      ),
    );
  }
}
