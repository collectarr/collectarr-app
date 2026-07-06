part of '../shell/library_edit_dialog.dart';

class _LibraryEditAnchorSelector extends StatelessWidget {
  const _LibraryEditAnchorSelector({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.editionAvailable,
    required this.bundleAvailable,
    required this.onChanged,
  });

  final Key fieldKey;
  final String label;
  final String value;
  final bool editionAvailable;
  final bool bundleAvailable;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: fieldKey,
      initialValue: value,
      isExpanded: true,
      dropdownColor: appPalette(context).panelRaised,
      borderRadius: kEditMenuBorderRadius,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem<String>(
          value: 'item',
          child: Text('Media'),
        ),
        if (editionAvailable)
          const DropdownMenuItem<String>(
            value: 'edition',
            child: Text('Edition'),
          ),
        if (editionAvailable)
          const DropdownMenuItem<String>(
            value: 'variant',
            child: Text('Variant'),
          ),
        if (bundleAvailable)
          const DropdownMenuItem<String>(
            value: 'bundle_release',
            child: Text('Bundle release'),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _LibraryEditEditionSelector extends StatelessWidget {
  const _LibraryEditEditionSelector({
    required this.label,
    required this.selectedEditionId,
    required this.editions,
    required this.onChanged,
  });

  final String label;
  final String? selectedEditionId;
  final List<CatalogEdition> editions;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedEditionId,
      isExpanded: true,
      dropdownColor: appPalette(context).panelRaised,
      borderRadius: kEditMenuBorderRadius,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem<String>(
          value: '',
          child: Text('Primary / unspecified edition'),
        ),
        for (final edition in editions)
          DropdownMenuItem<String>(
            value: edition.id,
            child: Text(edition.title),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _LibraryEditVariantSelector extends StatelessWidget {
  const _LibraryEditVariantSelector({
    required this.label,
    required this.selectedVariantId,
    required this.variants,
    required this.onChanged,
  });

  final String label;
  final String? selectedVariantId;
  final List<CatalogVariant> variants;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedVariantId,
      isExpanded: true,
      dropdownColor: appPalette(context).panelRaised,
      borderRadius: kEditMenuBorderRadius,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem<String>(
          value: '',
          child: Text('Any / unspecified variant'),
        ),
        for (final variant in variants)
          DropdownMenuItem<String>(
            value: variant.id,
            child: Text(variant.name),
          ),
      ],
      onChanged: variants.isEmpty ? null : onChanged,
    );
  }
}

class _LibraryEditBundleReleaseSelector extends StatelessWidget {
  const _LibraryEditBundleReleaseSelector({
    this.fieldKey,
    required this.label,
    required this.selectedBundleReleaseId,
    required this.bundleReleases,
    required this.onChanged,
  });

  final Key? fieldKey;
  final String label;
  final String? selectedBundleReleaseId;
  final List<BundleReleaseSummary> bundleReleases;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasSelectedBundleOutsideLoadedOptions =
        selectedBundleReleaseId != null &&
            bundleReleases.every(
              (bundle) => bundle.id != selectedBundleReleaseId,
            );
    return DropdownButtonFormField<String>(
      key: fieldKey,
      initialValue: selectedBundleReleaseId,
      isExpanded: true,
      dropdownColor: appPalette(context).panelRaised,
      borderRadius: kEditMenuBorderRadius,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem<String>(
          value: '',
          child: Text('Select a bundle release'),
        ),
        if (hasSelectedBundleOutsideLoadedOptions)
          DropdownMenuItem<String>(
            value: selectedBundleReleaseId,
            child: const Text('Current bundle release'),
          ),
        for (final bundle in bundleReleases)
          DropdownMenuItem<String>(
            value: bundle.id,
            child: Text(bundle.title),
          ),
      ],
      onChanged: bundleReleases.isEmpty ? null : onChanged,
    );
  }
}