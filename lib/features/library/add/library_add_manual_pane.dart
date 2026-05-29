part of 'library_add_dialog.dart';

class _ManualPane extends StatelessWidget {
  const _ManualPane({
    required this.type,
    required this.titleController,
    required this.numberController,
    required this.publisherController,
    required this.yearController,
    required this.barcodeController,
    required this.variantController,
    required this.coverController,
    required this.physicalFormats,
    required this.physicalFormatId,
    required this.onPhysicalFormatChanged,
    required this.isAdding,
    required this.onAddOwned,
    required this.onAddWishlist,
    required this.onAddTrack,
  });

  final LibraryTypeConfig type;
  final TextEditingController titleController;
  final TextEditingController numberController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final TextEditingController barcodeController;
  final TextEditingController variantController;
  final TextEditingController coverController;
  final List<PhysicalMediaFormat> physicalFormats;
  final String? physicalFormatId;
  final ValueChanged<String?> onPhysicalFormatChanged;
  final bool isAdding;
  final VoidCallback onAddOwned;
  final VoidCallback onAddWishlist;
  final VoidCallback onAddTrack;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final media = type.mediaFields;
    final release = type.releaseFields;
    final copyTypeLabel = ownedCopyTypeLabel(
      digitalPhysicalMediaFormatFlag(
        physicalFormatId,
        formats: physicalFormats,
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border(left: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.canvas,
                  border: Border.all(color: palette.divider),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    _ManualSectionHeader(
                      icon: type.workspace.icon,
                      label: 'Manual ${type.singularLabel}',
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: numberController,
                            textAlign: TextAlign.center,
                            decoration:
                                InputDecoration(labelText: media.numberLabel),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: yearController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textAlign: TextAlign.center,
                            decoration:
                                const InputDecoration(labelText: 'Year'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: publisherController,
                      decoration: InputDecoration(
                        labelText: media.publisherLabel,
                        prefixIcon: const Icon(Icons.business_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: variantController,
                      decoration: InputDecoration(
                        labelText: release.variantLabel,
                        prefixIcon:
                            const Icon(Icons.auto_awesome_motion_outlined),
                      ),
                    ),
                    if (physicalFormats.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: physicalFormatId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Physical format',
                          prefixIcon: Icon(Icons.album_outlined),
                        ),
                        dropdownColor: palette.panelRaised,
                        borderRadius: kAppMenuBorderRadius,
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('No specific format'),
                          ),
                          for (final format in physicalFormats)
                            DropdownMenuItem<String>(
                              value: format.id,
                              child: Text(format.label),
                            ),
                        ],
                        onChanged: onPhysicalFormatChanged,
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextField(
                      controller: barcodeController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: release.barcodeLabel,
                        prefixIcon: const Icon(Icons.qr_code_2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: coverController,
                      decoration: const InputDecoration(
                        labelText: 'Cover image URL',
                        prefixIcon: Icon(Icons.image_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: palette.panel,
                border: Border.all(color: palette.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        LibraryAddResultBadge('manual'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Start a local ${type.singularLabel.toLowerCase()} draft, then review full details',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (copyTypeLabel != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Owned copies created from this draft will be saved as $copyTypeLabel.',
                          style: TextStyle(
                            color: palette.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isAdding ? null : onAddTrack,
                            style: libraryAddOutlinedButtonStyle(),
                            icon: const Icon(Icons.visibility_outlined, size: 18),
                            label: Text(
                              LibraryAddCopy.addToTargetLabel(
                                count: 1,
                                type: type,
                                target: LibraryAddTarget.track,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isAdding ? null : onAddWishlist,
                            style: libraryAddOutlinedButtonStyle(),
                            icon: const Icon(Icons.star_outline, size: 18),
                            label: Text(
                              LibraryAddCopy.addToTargetLabel(
                                count: 1,
                                type: type,
                                target: LibraryAddTarget.wishlist,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: isAdding ? null : onAddOwned,
                            style: libraryAddFilledButtonStyle(),
                            icon: isAdding
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 18,
                                  ),
                            label: Text(
                              LibraryAddCopy.addToTargetLabel(
                                count: 1,
                                type: type,
                                target: LibraryAddTarget.owned,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualSectionHeader extends StatelessWidget {
  const _ManualSectionHeader({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kAppAccent),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
