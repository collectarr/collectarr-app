part of '../edit_dialog.dart';

extension _MusicEditServerCompare on _MusicLibraryEditDialogState {
  Future<void> _compareWithServerSnapshot() async {
    if (_isFetchingServerSnapshot) {
      return;
    }
    _updateState(() {
      _isFetchingServerSnapshot = true;
      _serverSnapshotError = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final snapshot = musicReleaseFromDto(await api.getMusicReleaseDto(_item.id));
      if (!mounted) {
        return;
      }
      _updateState(() {
        _serverSnapshotItem = snapshot;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _serverSnapshotError = _metadataCompareErrorMessage(error);
      });
    } finally {
      if (mounted) {
        _updateState(() {
          _isFetchingServerSnapshot = false;
        });
      }
    }
  }

  String _metadataCompareErrorMessage(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 422) {
        return 'Server rejected this compare request (422). '
            'This item likely has an unsupported metadata id format.';
      }
      final body = error.response?.data;
      if (body is Map<String, dynamic>) {
        final detail = body['detail']?.toString().trim();
        if (detail != null && detail.isNotEmpty) {
          return 'Could not load server metadata: $detail';
        }
      }
      if (statusCode != null) {
        return 'Could not load server metadata (HTTP $statusCode).';
      }
    }
    return 'Could not load the current metadata snapshot from the server.';
  }

  List<Map<String, dynamic>> get _serverCreators =>
      _serverSnapshotItem?.creators ?? const <Map<String, dynamic>>[];

  List<CatalogDisc> get _serverDiscs =>
      _serverSnapshotItem?.discs ?? const <CatalogDisc>[];

  List<String> _creatorsForRoleFromSource(
    List<Map<String, dynamic>> source,
    List<String> keywords,
  ) {
    final values = <String>[];
    for (final creator in source) {
      final role = creator['role']?.toString().toLowerCase() ?? '';
      if (!keywords.any(role.contains)) {
        continue;
      }
      final name = creator['name']?.toString().trim();
      if (name == null || name.isEmpty || values.contains(name)) {
        continue;
      }
      values.add(name);
    }
    return values;
  }

  List<MusicCreditEntry> _musicianEntriesFromSource(
    List<Map<String, dynamic>> source,
  ) {
    final values = <MusicCreditEntry>[];
    for (final creator in source) {
      final role = creator['role']?.toString().trim() ?? '';
      if (!_roleMatches(
        role,
        const ['musician', 'performer', 'instrumentalist'],
      )) {
        continue;
      }
      final rawName = creator['name']?.toString().trim() ?? '';
      if (rawName.isEmpty) {
        continue;
      }
      values.add(
        MusicCreditEntry(
          name: rawName,
          instrument: _extractInstrumentFromRole(role),
        ),
      );
    }
    return values;
  }

  List<MusicCreditEntry> _cloneMusicians(
    List<MusicCreditEntry> values,
  ) {
    return [
      for (final value in values)
        MusicCreditEntry(name: value.name, instrument: value.instrument),
    ];
  }

  String _formatNameList(List<String> values) {
    final normalized = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    return normalized.isEmpty ? '—' : normalized.join('\n');
  }

  String _formatMusicianList(List<MusicCreditEntry> values) {
    final normalized =
        values.where((value) => value.name.trim().isNotEmpty).map((value) {
      final instrument = value.instrument?.trim();
      if (instrument == null || instrument.isEmpty) {
        return value.name.trim();
      }
      return '${value.name.trim()} ($instrument)';
    }).toList(growable: false);
    return normalized.isEmpty ? '—' : normalized.join('\n');
  }

  String _formatDisc(CatalogDisc? disc) {
    if (disc == null) {
      return '—';
    }
    final lines = <String>[];
    if ((disc.discName ?? '').trim().isNotEmpty) {
      lines.add('Title: ${disc.discName!.trim()}');
    }
    if ((disc.storageDevice ?? '').trim().isNotEmpty) {
      lines.add('Storage: ${disc.storageDevice!.trim()}');
    }
    if ((disc.slot ?? '').trim().isNotEmpty) {
      lines.add('Slot: ${disc.slot!.trim()}');
    }
    if ((disc.matrixSideA ?? '').trim().isNotEmpty) {
      lines.add('Matrix A: ${disc.matrixSideA!.trim()}');
    }
    if ((disc.matrixSideB ?? '').trim().isNotEmpty) {
      lines.add('Matrix B: ${disc.matrixSideB!.trim()}');
    }
    if (lines.isEmpty) {
      return 'Disc #${disc.discNumber}';
    }
    return lines.join('\n');
  }

  String _diffText(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? '—' : normalized;
  }

  String _diffDate(DateTime? value) {
    return value == null ? '—' : formatDate(value);
  }

  String _diffList(Iterable<String>? values) {
    if (values == null) {
      return '—';
    }
    final normalized = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (normalized.isEmpty) {
      return '—';
    }
    return normalized.join(', ');
  }

  List<MetadataDiffEntry> _musicMetadataDiffEntries(MusicRelease serverItem) {
    return [
      MetadataDiffEntry(
        label: 'Title',
        localValue: _diffText(_titleController.text),
        serverValue: _diffText(serverItem.title),
      ),
      MetadataDiffEntry(
        label: 'Sort title',
        localValue: _diffText(_sortKeyController.text),
        serverValue: _diffText(serverItem.sortTitle),
      ),
      MetadataDiffEntry(
        label: 'Artist',
        localValue: _diffText(_artistController.text),
        serverValue: _diffText(serverItem.artist),
      ),
      MetadataDiffEntry(
        label: 'Subtitle',
        localValue: _diffText(_subtitleController.text),
        serverValue: _diffText(serverItem.subtitle),
      ),
      MetadataDiffEntry(
        label: 'Label',
        localValue: _diffText(_publisherController.text),
        serverValue: _diffText(serverItem.publisher),
      ),
      MetadataDiffEntry(
        label: 'Release date',
        localValue: _diffText(_releaseDateController.text),
        serverValue: _diffDate(serverItem.releaseDate),
      ),
      MetadataDiffEntry(
        label: 'Original release date',
        localValue: _diffText(_originalReleaseDateController.text),
        serverValue: _diffDate(serverItem.originalReleaseDate),
      ),
      MetadataDiffEntry(
        label: 'Recording date',
        localValue: _diffText(_recordingDateController.text),
        serverValue: _diffDate(serverItem.recordingDate),
      ),
      MetadataDiffEntry(
        label: 'Release status',
        localValue: _diffText(_releaseStatusController.text),
        serverValue: _diffText(serverItem.releaseStatus),
      ),
      MetadataDiffEntry(
        label: 'Catalog number',
        localValue: _diffText(_catalogNumberController.text),
        serverValue: _diffText(serverItem.catalogNumber),
      ),
      MetadataDiffEntry(
        label: 'Country',
        localValue: _diffText(_countryController.text),
        serverValue: _diffText(serverItem.countryCode),
      ),
      MetadataDiffEntry(
        label: 'Language',
        localValue: _diffText(_languageController.text),
        serverValue: _diffText(serverItem.language),
      ),
      MetadataDiffEntry(
        label: 'Genres',
        localValue: _diffList(_genreValues),
        serverValue: _diffList(serverItem.genres),
      ),
      MetadataDiffEntry(
        label: 'Instrument',
        localValue: _diffText(_instrumentController.text),
        serverValue: _diffText(serverItem.instrument),
      ),
      MetadataDiffEntry(
        label: 'Composition',
        localValue: _diffText(_compositionController.text),
        serverValue: _diffText(serverItem.composition),
      ),
      MetadataDiffEntry(
        label: 'RPM',
        localValue: _diffText(_rpmController.text),
        serverValue: _diffText(serverItem.rpm),
      ),
      MetadataDiffEntry(
        label: 'SPARS',
        localValue: _diffText(_sparsController.text),
        serverValue: _diffText(serverItem.spars),
      ),
      MetadataDiffEntry(
        label: 'Sound',
        localValue: _diffList(_soundValues),
        serverValue: _diffText(serverItem.soundType),
      ),
      MetadataDiffEntry(
        label: 'Vinyl color',
        localValue: _diffText(_vinylColorController.text),
        serverValue: _diffText(serverItem.vinylColor),
      ),
      MetadataDiffEntry(
        label: 'Vinyl weight',
        localValue: _diffText(_vinylWeightController.text),
        serverValue: _diffText(serverItem.vinylWeight),
      ),
      MetadataDiffEntry(
        label: 'Media condition',
        localValue: _diffText(_mediaConditionController.text),
        serverValue: _diffText(serverItem.mediaCondition),
      ),
      MetadataDiffEntry(
        label: 'Packaging',
        localValue: _diffText(_packagingController.text),
        serverValue: '—',
      ),
      MetadataDiffEntry(
        label: 'Extras',
        localValue: _diffText(_extrasController.text),
        serverValue: '—',
      ),
      MetadataDiffEntry(
        label: 'Live recording',
        localValue: _isLive ? 'Yes' : 'No',
        serverValue: serverItem.isLive ? 'Yes' : 'No',
      ),
    ];
  }

  Widget _serverSnapshotCompareSection({
    required bool showCreatorsDiff,
    required bool showDiscsDiff,
  }) {
    final localDiscs = {
      for (final disc in _buildSubmittedDiscMetadata()) disc.discNumber: disc,
    };
    final serverDiscs = {
      for (final disc in _serverDiscs) disc.discNumber: disc,
    };
    final allDiscNumbers =
        <int>{...localDiscs.keys, ...serverDiscs.keys}.toList()..sort();

    final serverComposer =
        _creatorsForRoleFromSource(_serverCreators, const ['composer']);
    final serverConductor =
        _creatorsForRoleFromSource(_serverCreators, const ['conductor']);
    final serverOrchestra = _creatorsForRoleFromSource(
      _serverCreators,
      const ['orchestra', 'ensemble'],
    );
    final serverChorus = _creatorsForRoleFromSource(
      _serverCreators,
      const ['chorus', 'choir'],
    );
    final serverSongwriter = _creatorsForRoleFromSource(
      _serverCreators,
      const ['songwriter', 'lyricist'],
    );
    final serverProducer =
        _creatorsForRoleFromSource(_serverCreators, const ['producer']);
    final serverEngineer =
        _creatorsForRoleFromSource(_serverCreators, const ['engineer']);
    final serverMusicians = _musicianEntriesFromSource(_serverCreators);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_serverSnapshotError != null) ...[
          const SizedBox(height: 6),
          Text(
            _serverSnapshotError!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.redAccent),
          ),
        ],
        if (_serverSnapshotItem != null) ...[
          const SizedBox(height: 8),
          MetadataDiffPanel(
            title: 'Metadata fields diff (Local vs Server)',
            entries: _musicMetadataDiffEntries(_serverSnapshotItem!),
            emptyText: 'No field-level differences found.',
          ),
        ],
        if (_serverSnapshotItem != null && showCreatorsDiff) ...[
          const SizedBox(height: 8),
          MetadataDiffPanel(
            title: 'Creators diff (Local vs Server)',
            entries: [
              MetadataDiffEntry(
                label: 'Composer',
                localValue: _formatNameList(_composerCredits),
                serverValue: _formatNameList(serverComposer),
                onAccept: () => _updateState(
                  () => _composerCredits = List<String>.from(serverComposer),
                ),
              ),
              MetadataDiffEntry(
                label: 'Conductor',
                localValue: _formatNameList(_conductorCredits),
                serverValue: _formatNameList(serverConductor),
                onAccept: () => _updateState(
                  () => _conductorCredits = List<String>.from(serverConductor),
                ),
              ),
              MetadataDiffEntry(
                label: 'Orchestra',
                localValue: _formatNameList(_orchestraCredits),
                serverValue: _formatNameList(serverOrchestra),
                onAccept: () => _updateState(
                  () => _orchestraCredits = List<String>.from(serverOrchestra),
                ),
              ),
              MetadataDiffEntry(
                label: 'Chorus',
                localValue: _formatNameList(_chorusCredits),
                serverValue: _formatNameList(serverChorus),
                onAccept: () => _updateState(
                  () => _chorusCredits = List<String>.from(serverChorus),
                ),
              ),
              MetadataDiffEntry(
                label: 'Songwriter',
                localValue: _formatNameList(_songwriterCredits),
                serverValue: _formatNameList(serverSongwriter),
                onAccept: () => _updateState(
                  () =>
                      _songwriterCredits = List<String>.from(serverSongwriter),
                ),
              ),
              MetadataDiffEntry(
                label: 'Producer',
                localValue: _formatNameList(_producerCredits),
                serverValue: _formatNameList(serverProducer),
                onAccept: () => _updateState(
                  () => _producerCredits = List<String>.from(serverProducer),
                ),
              ),
              MetadataDiffEntry(
                label: 'Engineer',
                localValue: _formatNameList(_engineerCredits),
                serverValue: _formatNameList(serverEngineer),
                onAccept: () => _updateState(
                  () => _engineerCredits = List<String>.from(serverEngineer),
                ),
              ),
              MetadataDiffEntry(
                label: 'Musicians',
                localValue: _formatMusicianList(_musicianCredits),
                serverValue: _formatMusicianList(serverMusicians),
                onAccept: () => _updateState(
                  () => _musicianCredits = _cloneMusicians(serverMusicians),
                ),
              ),
            ],
            onAcceptAll: () {
              _updateState(() {
                _composerCredits = List<String>.from(serverComposer);
                _conductorCredits = List<String>.from(serverConductor);
                _orchestraCredits = List<String>.from(serverOrchestra);
                _chorusCredits = List<String>.from(serverChorus);
                _songwriterCredits = List<String>.from(serverSongwriter);
                _producerCredits = List<String>.from(serverProducer);
                _engineerCredits = List<String>.from(serverEngineer);
                _musicianCredits = _cloneMusicians(serverMusicians);
              });
            },
          ),
        ],
        if (_serverSnapshotItem != null && showDiscsDiff) ...[
          const SizedBox(height: 8),
          MetadataDiffPanel(
            title: 'Discs diff (Local vs Server)',
            entries: [
              for (final discNumber in allDiscNumbers)
                MetadataDiffEntry(
                  label: 'Disc #$discNumber',
                  localValue: _formatDisc(localDiscs[discNumber]),
                  serverValue: _formatDisc(serverDiscs[discNumber]),
                  onAccept: serverDiscs[discNumber] == null
                      ? null
                      : () => _applyServerDisc(discNumber),
                ),
            ],
            onAcceptAll: serverDiscs.isEmpty ? null : _applyAllServerDiscs,
          ),
        ],
      ],
    );
  }

  void _ensureDiscExists(int discNumber) {
    if (_editableTrackRows.any((row) => row.discNumber == discNumber)) {
      return;
    }
    _editableTrackRows.add(
      _createTrackRow(
        discNumber: discNumber,
        position: 1,
        title: '',
        artist: '',
        durationLabel: '',
      ),
    );
    _renumberDiscTracks(discNumber);
  }

  void _applyServerDiscValue(CatalogDisc disc) {
    _ensureDiscExists(disc.discNumber);
    final draft = _discDraftFor(disc.discNumber);
    draft.discTitleController.text =
        disc.discName ?? 'Disc #${disc.discNumber}';
    draft.storageDeviceController.text = disc.storageDevice ?? '';
    draft.slotController.text = disc.slot ?? '';
    draft.matrixSideAController.text = disc.matrixSideA ?? '';
    draft.matrixSideBController.text = disc.matrixSideB ?? '';
  }

  void _applyServerDisc(int discNumber) {
    CatalogDisc? serverDisc;
    for (final disc in _serverDiscs) {
      if (disc.discNumber == discNumber) {
        serverDisc = disc;
        break;
      }
    }
    if (serverDisc == null) {
      return;
    }
    _updateState(() => _applyServerDiscValue(serverDisc!));
  }

  void _applyAllServerDiscs() {
    if (_serverDiscs.isEmpty) {
      return;
    }
    _updateState(() {
      for (final disc in _serverDiscs) {
        _applyServerDiscValue(disc);
      }
    });
  }
}
