part of 'admin_page.dart';

class _BundleReleaseCorrectionDialog extends StatefulWidget {
  const _BundleReleaseCorrectionDialog({required this.bundle});

  final BundleReleaseDetail bundle;

  @override
  State<_BundleReleaseCorrectionDialog> createState() =>
      _BundleReleaseCorrectionDialogState();
}

class _BundleReleaseCorrectionDialogState
    extends State<_BundleReleaseCorrectionDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _bundleTypeController;
  late final TextEditingController _formatController;
  late final TextEditingController _variantTypeController;
  late final TextEditingController _packagingTypeController;
  late final TextEditingController _regionController;
  late final TextEditingController _languageController;
  late final TextEditingController _publisherController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _releaseDateController;
  late final TextEditingController _coverController;
  late final TextEditingController _thumbnailController;
  late final List<_EditableBundleMember> _members;
  String? _error;

  @override
  void initState() {
    super.initState();
    final bundle = widget.bundle;
    _titleController = TextEditingController(text: bundle.title);
    _bundleTypeController = TextEditingController(text: bundle.bundleType ?? '');
    _formatController = TextEditingController(text: bundle.format ?? '');
    _variantTypeController = TextEditingController(text: bundle.variantType ?? '');
    _packagingTypeController = TextEditingController(text: bundle.packagingType ?? '');
    _regionController = TextEditingController(text: bundle.region ?? '');
    _languageController = TextEditingController(text: bundle.language ?? '');
    _publisherController = TextEditingController(text: bundle.publisher ?? '');
    _skuController = TextEditingController(text: bundle.sku ?? '');
    _barcodeController = TextEditingController(text: bundle.barcode ?? '');
    _releaseDateController = TextEditingController(
      text: bundle.releaseDate == null ? '' : _formatDate(bundle.releaseDate!),
    );
    _coverController = TextEditingController(text: bundle.coverImageUrl ?? '');
    _thumbnailController = TextEditingController(text: bundle.thumbnailImageUrl ?? '');
    _members = bundle.members
        .map(_EditableBundleMember.fromExisting)
        .toList(growable: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bundleTypeController.dispose();
    _formatController.dispose();
    _variantTypeController.dispose();
    _packagingTypeController.dispose();
    _regionController.dispose();
    _languageController.dispose();
    _publisherController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _releaseDateController.dispose();
    _coverController.dispose();
    _thumbnailController.dispose();
    for (final member in _members) {
      member.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      shape: _kAdminDialogShape,
      title: Text('Edit bundle: ${widget.bundle.title}'),
      content: SizedBox(
        width: 760,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                _MessageRow(message: _error!, isError: true),
                const SizedBox(height: 12),
              ],
              _correctionField(_titleController, 'Title'),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 220,
                    child: _correctionField(_bundleTypeController, 'Bundle type'),
                  ),
                  SizedBox(
                    width: 220,
                    child: _correctionField(_formatController, 'Format'),
                  ),
                  SizedBox(
                    width: 220,
                    child: _correctionField(_variantTypeController, 'Variant type'),
                  ),
                  SizedBox(
                    width: 220,
                    child: _correctionField(_packagingTypeController, 'Packaging type'),
                  ),
                  SizedBox(
                    width: 220,
                    child: _correctionField(_regionController, 'Region'),
                  ),
                  SizedBox(
                    width: 220,
                    child: _correctionField(_languageController, 'Language'),
                  ),
                  SizedBox(
                    width: 220,
                    child: _correctionField(_publisherController, 'Publisher'),
                  ),
                  SizedBox(
                    width: 220,
                    child: _correctionField(_skuController, 'SKU'),
                  ),
                  SizedBox(
                    width: 220,
                    child: _correctionField(_barcodeController, 'Barcode'),
                  ),
                  SizedBox(
                    width: 220,
                    child: _correctionField(_releaseDateController, 'Release date'),
                  ),
                ],
              ),
              _correctionField(_coverController, 'Cover URL'),
              _correctionField(_thumbnailController, 'Thumbnail URL'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bundle members',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _addMember,
                    icon: const Icon(Icons.add_outlined),
                    label: const Text('Add member'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (var index = 0; index < _members.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _memberCard(_members[index], index),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save correction'),
        ),
      ],
    );
  }

  Widget _correctionField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _memberCard(_EditableBundleMember member, int index) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    member.displayLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Checkbox(
                  value: member.isPrimary,
                  onChanged: (value) {
                    setState(() {
                      member.isPrimary = value ?? false;
                    });
                  },
                ),
                const Text('Primary'),
                IconButton(
                  tooltip: 'Remove member',
                  onPressed: () => _removeMember(index),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 300,
                  child: _correctionField(member.itemIdController, 'Item ID'),
                ),
                SizedBox(
                  width: 160,
                  child: _correctionField(member.roleController, 'Role'),
                ),
                SizedBox(
                  width: 120,
                  child: _correctionField(
                    member.sequenceController,
                    'Sequence',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: _correctionField(
                    member.discNumberController,
                    'Disc',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: _correctionField(member.discLabelController, 'Disc label'),
                ),
                SizedBox(
                  width: 120,
                  child: _correctionField(
                    member.quantityController,
                    'Quantity',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addMember() {
    setState(() {
      _members.add(_EditableBundleMember.newMember());
    });
  }

  void _removeMember(int index) {
    setState(() {
      final member = _members.removeAt(index);
      member.dispose();
    });
  }

  Future<void> _submit() async {
    final normalizedTitle = _titleController.text.trim();
    if (normalizedTitle.isEmpty) {
      setState(() {
        _error = 'Title is required.';
      });
      return;
    }
    if (_members.isEmpty) {
      setState(() {
        _error = 'Bundle releases must keep at least one member.';
      });
      return;
    }
    final primaryCount = _members.where((member) => member.isPrimary).length;
    if (primaryCount != 1) {
      setState(() {
        _error = 'Mark exactly one bundle member as primary.';
      });
      return;
    }

    final memberUpdates = <AdminBundleReleaseMemberUpdate>[];
    try {
      for (final member in _members) {
        final itemId = _emptyToNull(member.itemIdController.text);
        if (itemId == null) {
          throw const FormatException('Each member must have an item ID.');
        }
        final role = _emptyToNull(member.roleController.text);
        if (role == null) {
          throw const FormatException('Each member must have a role.');
        }
        final sequenceNumber = _optionalInt(member.sequenceController.text, 'sequence');
        final discNumber = _optionalInt(member.discNumberController.text, 'disc');
        final quantity = _requiredPositiveInt(member.quantityController.text, 'quantity');
        memberUpdates.add(
          AdminBundleReleaseMemberUpdate(
            id: member.memberId,
            itemId: itemId,
            role: role,
            sequenceNumber: sequenceNumber,
            discNumber: discNumber,
            discLabel: _emptyToNull(member.discLabelController.text),
            quantity: quantity,
            isPrimary: member.isPrimary,
          ),
        );
      }
    } on FormatException catch (error) {
      setState(() {
        _error = error.message;
      });
      return;
    }

    final releaseDateText = _releaseDateController.text.trim();
    final releaseDate =
        releaseDateText.isEmpty ? null : DateTime.tryParse(releaseDateText);
    if (releaseDateText.isNotEmpty && releaseDate == null) {
      setState(() {
        _error = 'Release date must use YYYY-MM-DD.';
      });
      return;
    }

    final correction = AdminBundleReleaseCorrection(
      title: _changedText(_titleController.text, widget.bundle.title),
      bundleType: _changedText(_bundleTypeController.text, widget.bundle.bundleType),
      format: _changedText(_formatController.text, widget.bundle.format),
      variantType: _changedText(_variantTypeController.text, widget.bundle.variantType),
      packagingType: _changedText(
        _packagingTypeController.text,
        widget.bundle.packagingType,
      ),
      region: _changedText(_regionController.text, widget.bundle.region),
      language: _changedText(_languageController.text, widget.bundle.language),
      publisher: _changedText(_publisherController.text, widget.bundle.publisher),
      sku: _changedText(_skuController.text, widget.bundle.sku),
      barcode: _changedText(_barcodeController.text, widget.bundle.barcode),
      releaseDate:
          releaseDate != null && !_sameUtcDate(releaseDate, widget.bundle.releaseDate)
              ? releaseDate
              : null,
      coverImageUrl: _changedText(_coverController.text, widget.bundle.coverImageUrl),
      thumbnailImageUrl: _changedText(
        _thumbnailController.text,
        widget.bundle.thumbnailImageUrl,
      ),
      members: memberUpdates,
    );

    final changes = <_CorrectionPreviewEntry>[];
    void add(String label, Object? before, Object? after) {
      final beforeText = _previewBundleValue(before);
      final afterText = _previewBundleValue(after);
      if (beforeText == afterText) {
        return;
      }
      changes.add(
        _CorrectionPreviewEntry(
          label: label,
          before: beforeText,
          after: afterText,
        ),
      );
    }

    add('Title', widget.bundle.title, correction.title ?? widget.bundle.title);
    add(
      'Bundle type',
      widget.bundle.bundleType,
      correction.bundleType ?? widget.bundle.bundleType,
    );
    add('Format', widget.bundle.format, correction.format ?? widget.bundle.format);
    add(
      'Variant type',
      widget.bundle.variantType,
      correction.variantType ?? widget.bundle.variantType,
    );
    add(
      'Packaging type',
      widget.bundle.packagingType,
      correction.packagingType ?? widget.bundle.packagingType,
    );
    add('Region', widget.bundle.region, correction.region ?? widget.bundle.region);
    add(
      'Language',
      widget.bundle.language,
      correction.language ?? widget.bundle.language,
    );
    add(
      'Publisher',
      widget.bundle.publisher,
      correction.publisher ?? widget.bundle.publisher,
    );
    add('SKU', widget.bundle.sku, correction.sku ?? widget.bundle.sku);
    add('Barcode', widget.bundle.barcode, correction.barcode ?? widget.bundle.barcode);
    add(
      'Release date',
      widget.bundle.releaseDate,
      correction.releaseDate ?? widget.bundle.releaseDate,
    );
    add(
      'Cover URL',
      widget.bundle.coverImageUrl,
      correction.coverImageUrl ?? widget.bundle.coverImageUrl,
    );
    add(
      'Thumbnail URL',
      widget.bundle.thumbnailImageUrl,
      correction.thumbnailImageUrl ?? widget.bundle.thumbnailImageUrl,
    );
    add(
      'Members',
      _bundleMembersPreview(widget.bundle.members),
      _bundleMembersDraftPreview(_members),
    );

    if (changes.isEmpty) {
      setState(() {
        _error = 'Change at least one bundle field or member before saving.';
      });
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AccentAlertDialog(
            shape: _kAdminDialogShape,
            title: const Text('Preview bundle correction'),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _DestructiveWarning(
                      icon: Icons.inventory_2_outlined,
                      message:
                          'This edits canonical bundle metadata and affects every user who attaches ownership to this bundle.',
                    ),
                    const SizedBox(height: 12),
                    for (final change in changes)
                      _CorrectionPreviewRow(change: change),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Back to edit'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save correction'),
              ),
            ],
          ),
        ) ??
        false;
    if (!mounted || !confirmed) {
      return;
    }
    Navigator.of(context).pop(correction);
  }

  String? _changedText(String value, String? original) {
    final normalized = _emptyToNull(value);
    final previous = _emptyToNull(original ?? '');
    if (normalized == null || normalized == previous) {
      return null;
    }
    return normalized;
  }

  int? _optionalInt(String value, String label) {
    final normalized = _emptyToNull(value);
    if (normalized == null) {
      return null;
    }
    final parsed = int.tryParse(normalized);
    if (parsed == null || parsed <= 0) {
      throw FormatException(
        '${label[0].toUpperCase()}${label.substring(1)} must be a positive number.',
      );
    }
    return parsed;
  }

  int _requiredPositiveInt(String value, String label) {
    final normalized = _emptyToNull(value);
    final parsed = normalized == null ? null : int.tryParse(normalized);
    if (parsed == null || parsed <= 0) {
      throw FormatException(
        '${label[0].toUpperCase()}${label.substring(1)} must be a positive number.',
      );
    }
    return parsed;
  }

  String _previewBundleValue(Object? value) {
    if (value == null) {
      return '(unchanged)';
    }
    if (value is DateTime) {
      return _formatDate(value);
    }
    final text = value.toString().trim();
    return text.isEmpty ? '(unchanged)' : text;
  }

  String _bundleMembersPreview(List<BundleReleaseMember> members) {
    if (members.isEmpty) {
      return '(empty)';
    }
    return members
        .map((member) {
          final parts = <String>[member.role];
          if (member.isPrimary) {
            parts.add('primary');
          }
          if (member.sequenceNumber != null) {
            parts.add('seq ${member.sequenceNumber}');
          }
          if (member.discNumber != null) {
            parts.add('disc ${member.discNumber}');
          }
          return '${member.title} (${parts.join(', ')})';
        })
        .join(' | ');
  }

  String _bundleMembersDraftPreview(List<_EditableBundleMember> members) {
    if (members.isEmpty) {
      return '(empty)';
    }
    return members
        .map((member) {
          final parts = <String>[member.roleController.text.trim()];
          if (member.isPrimary) {
            parts.add('primary');
          }
          final sequence = _emptyToNull(member.sequenceController.text);
          if (sequence != null) {
            parts.add('seq $sequence');
          }
          final disc = _emptyToNull(member.discNumberController.text);
          if (disc != null) {
            parts.add('disc $disc');
          }
          return '${member.displayLabel} (${parts.join(', ')})';
        })
        .join(' | ');
  }

  bool _sameUtcDate(DateTime first, DateTime? second) {
    if (second == null) {
      return false;
    }
    final a = first.toUtc();
    final b = second.toUtc();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _EditableBundleMember {
  _EditableBundleMember._({
    required this.memberId,
    required this.initialLabel,
    required this.itemIdController,
    required this.roleController,
    required this.sequenceController,
    required this.discNumberController,
    required this.discLabelController,
    required this.quantityController,
    required this.isPrimary,
  });

  factory _EditableBundleMember.fromExisting(BundleReleaseMember member) {
    return _EditableBundleMember._(
      memberId: member.id,
      initialLabel: member.title,
      itemIdController: TextEditingController(text: member.itemId),
      roleController: TextEditingController(text: member.role),
      sequenceController:
          TextEditingController(text: member.sequenceNumber?.toString() ?? ''),
      discNumberController:
          TextEditingController(text: member.discNumber?.toString() ?? ''),
      discLabelController: TextEditingController(text: member.discLabel ?? ''),
      quantityController: TextEditingController(text: member.quantity.toString()),
      isPrimary: member.isPrimary,
    );
  }

  factory _EditableBundleMember.newMember() {
    return _EditableBundleMember._(
      memberId: null,
      initialLabel: 'New member',
      itemIdController: TextEditingController(),
      roleController: TextEditingController(text: 'member'),
      sequenceController: TextEditingController(),
      discNumberController: TextEditingController(),
      discLabelController: TextEditingController(),
      quantityController: TextEditingController(text: '1'),
      isPrimary: false,
    );
  }

  final String? memberId;
  final String initialLabel;
  final TextEditingController itemIdController;
  final TextEditingController roleController;
  final TextEditingController sequenceController;
  final TextEditingController discNumberController;
  final TextEditingController discLabelController;
  final TextEditingController quantityController;
  bool isPrimary;

  String get displayLabel {
    final itemId = itemIdController.text.trim();
    if (initialLabel.isNotEmpty && initialLabel != 'New member') {
      return initialLabel;
    }
    return itemId.isEmpty ? initialLabel : itemId;
  }

  void dispose() {
    itemIdController.dispose();
    roleController.dispose();
    sequenceController.dispose();
    discNumberController.dispose();
    discLabelController.dispose();
    quantityController.dispose();
  }
}