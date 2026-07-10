import 'package:flutter/material.dart';

enum LibraryViewMode { grid, card, horizontalCards, cardFlow, list, shelves }

enum LibraryWorkspaceBrowserMode { media, releases }

enum LibraryWorkspaceDensityPreset { comfortable, compact, ultraCompact }

extension LibraryViewModeCoverSizeSupport on LibraryViewMode {
  bool get supportsCoverSize {
    return switch (this) {
      LibraryViewMode.grid ||
      LibraryViewMode.card ||
      LibraryViewMode.horizontalCards ||
      LibraryViewMode.shelves =>
        true,
      LibraryViewMode.cardFlow || LibraryViewMode.list => false,
    };
  }
}

enum LibraryDetailsLayout { right, bottom, hidden }

enum LibraryFolderDisplayMode { drilldown, tree }

extension LibraryFolderDisplayModeLabels on LibraryFolderDisplayMode {
  String get label {
    return switch (this) {
      LibraryFolderDisplayMode.drilldown => 'Drilldown',
      LibraryFolderDisplayMode.tree => 'Tree',
    };
  }

  IconData get icon {
    return switch (this) {
      LibraryFolderDisplayMode.drilldown => Icons.segment,
      LibraryFolderDisplayMode.tree => Icons.account_tree_outlined,
    };
  }
}

enum LibraryWorkspacePreset { cover, card, list, details }

extension LibraryWorkspacePresetLabels on LibraryWorkspacePreset {
  String get label {
    return switch (this) {
      LibraryWorkspacePreset.cover => 'Grid',
      LibraryWorkspacePreset.card => 'Cards',
      LibraryWorkspacePreset.list => 'List',
      LibraryWorkspacePreset.details => 'Details panel',
    };
  }

  IconData get icon {
    return switch (this) {
      LibraryWorkspacePreset.cover => Icons.grid_view,
      LibraryWorkspacePreset.card => Icons.view_module,
      LibraryWorkspacePreset.list => Icons.view_list,
      LibraryWorkspacePreset.details => Icons.view_sidebar,
    };
  }
}

extension type const LibraryGroupMode(String name) implements String {
  // Main
  static const series = LibraryGroupMode('series');
  static const storyArc = LibraryGroupMode('storyArc');
  static const character = LibraryGroupMode('character');
  static const title = LibraryGroupMode('title');
  static const publisher = LibraryGroupMode('publisher');
  static const year = LibraryGroupMode('year');
  static const audienceRating = LibraryGroupMode('audienceRating');
  static const color = LibraryGroupMode('color');
  static const genre = LibraryGroupMode('genre');
  static const platform = LibraryGroupMode('platform');
  static const developer = LibraryGroupMode('developer');
  static const country = LibraryGroupMode('country');
  static const language = LibraryGroupMode('language');
  static const ageRating = LibraryGroupMode('ageRating');
  static const crossover = LibraryGroupMode('crossover');
  static const imprint = LibraryGroupMode('imprint');
  static const seriesGroup = LibraryGroupMode('seriesGroup');
  static const movieOrTvSeries = LibraryGroupMode('movieOrTvSeries');
  static const releaseDate = LibraryGroupMode('releaseDate');
  static const releaseMonth = LibraryGroupMode('releaseMonth');
  static const releaseYear = LibraryGroupMode('releaseYear');
  static const publicationPlace = LibraryGroupMode('publicationPlace');
  static const originalReleaseDate = LibraryGroupMode('originalReleaseDate');
  static const originalReleaseMonth = LibraryGroupMode('originalReleaseMonth');
  static const originalReleaseYear = LibraryGroupMode('originalReleaseYear');
  static const originalCountry = LibraryGroupMode('originalCountry');
  static const originalLanguage = LibraryGroupMode('originalLanguage');
  static const originalPublicationDate = LibraryGroupMode('originalPublicationDate');
  static const originalPublicationMonth = LibraryGroupMode('originalPublicationMonth');
  static const originalPublicationYear = LibraryGroupMode('originalPublicationYear');
  static const originalPublicationPlace = LibraryGroupMode('originalPublicationPlace');
  static const originalPublisher = LibraryGroupMode('originalPublisher');
  static const recordingDate = LibraryGroupMode('recordingDate');
  static const recordingMonth = LibraryGroupMode('recordingMonth');
  static const recordingYear = LibraryGroupMode('recordingYear');
  static const coverDate = LibraryGroupMode('coverDate');
  static const coverMonth = LibraryGroupMode('coverMonth');
  static const coverYear = LibraryGroupMode('coverYear');
  
  // Edition
  static const audioTracks = LibraryGroupMode('audioTracks');
  static const boxSet = LibraryGroupMode('boxSet');
  static const completeness = LibraryGroupMode('completeness');
  static const valueLocked = LibraryGroupMode('valueLocked');
  static const dustJacketCondition = LibraryGroupMode('dustJacketCondition');
  static const distributor = LibraryGroupMode('distributor');
  static const instrument = LibraryGroupMode('instrument');
  static const isLive = LibraryGroupMode('isLive');
  static const mediaCondition = LibraryGroupMode('mediaCondition');
  static const rpm = LibraryGroupMode('rpm');
  static const spars = LibraryGroupMode('spars');
  static const soundType = LibraryGroupMode('soundType');
  static const studio = LibraryGroupMode('studio');
  static const vinylColor = LibraryGroupMode('vinylColor');
  static const toySubtype = LibraryGroupMode('toySubtype');
  static const toyType = LibraryGroupMode('toyType');
  static const edition = LibraryGroupMode('edition');
  static const audiobookAbridged = LibraryGroupMode('audiobookAbridged');
  static const firstEdition = LibraryGroupMode('firstEdition');
  static const narrator = LibraryGroupMode('narrator');
  static const paperType = LibraryGroupMode('paperType');
  static const printedBy = LibraryGroupMode('printedBy');
  static const editionReleaseDate = LibraryGroupMode('editionReleaseDate');
  static const editionReleaseMonth = LibraryGroupMode('editionReleaseMonth');
  static const editionReleaseYear = LibraryGroupMode('editionReleaseYear');
  static const extras = LibraryGroupMode('extras');
  static const format = LibraryGroupMode('format');
  static const hdr = LibraryGroupMode('hdr');
  static const layers = LibraryGroupMode('layers');
  static const packaging = LibraryGroupMode('packaging');
  static const regions = LibraryGroupMode('regions');
  static const screenRatios = LibraryGroupMode('screenRatios');
  static const subtitles = LibraryGroupMode('subtitles');
  
  // Cast & Crew
  static const actor = LibraryGroupMode('actor');
  static const chorus = LibraryGroupMode('chorus');
  static const composer = LibraryGroupMode('composer');
  static const composition = LibraryGroupMode('composition');
  static const conductor = LibraryGroupMode('conductor');
  static const engineer = LibraryGroupMode('engineer');
  static const director = LibraryGroupMode('director');
  static const musician = LibraryGroupMode('musician');
  static const orchestra = LibraryGroupMode('orchestra');
  static const photography = LibraryGroupMode('photography');
  static const producer = LibraryGroupMode('producer');
  static const writer = LibraryGroupMode('writer');
  static const creator = LibraryGroupMode('creator');
  static const artist = LibraryGroupMode('artist');
  static const penciller = LibraryGroupMode('penciller');
  static const inker = LibraryGroupMode('inker');
  static const colorist = LibraryGroupMode('colorist');
  static const painter = LibraryGroupMode('painter');
  static const letterer = LibraryGroupMode('letterer');
  static const separator = LibraryGroupMode('separator');
  static const layouts = LibraryGroupMode('layouts');
  static const translator = LibraryGroupMode('translator');
  static const plotter = LibraryGroupMode('plotter');
  static const scripter = LibraryGroupMode('scripter');
  static const coverArtist = LibraryGroupMode('coverArtist');
  static const coverPenciller = LibraryGroupMode('coverPenciller');
  static const coverPainter = LibraryGroupMode('coverPainter');
  static const coverInker = LibraryGroupMode('coverInker');
  static const coverColorist = LibraryGroupMode('coverColorist');
  static const coverSeparator = LibraryGroupMode('coverSeparator');
  static const editor = LibraryGroupMode('editor');
  static const editorInChief = LibraryGroupMode('editorInChief');
  static const forewordAuthor = LibraryGroupMode('forewordAuthor');
  static const ghostWriter = LibraryGroupMode('ghostWriter');
  static const illustrator = LibraryGroupMode('illustrator');
  
  // Personal
  static const location = LibraryGroupMode('location');
  static const ownership = LibraryGroupMode('ownership');
  static const addedDate = LibraryGroupMode('addedDate');
  static const addedMonth = LibraryGroupMode('addedMonth');
  static const addedYear = LibraryGroupMode('addedYear');
  static const collectionStatus = LibraryGroupMode('collectionStatus');
  static const grade = LibraryGroupMode('grade');
  static const condition = LibraryGroupMode('condition');
  static const rawOrSlabbed = LibraryGroupMode('rawOrSlabbed');
  static const isKeyComic = LibraryGroupMode('isKeyComic');
  static const imageType = LibraryGroupMode('imageType');
  static const modifiedDate = LibraryGroupMode('modifiedDate');
  static const modifiedMonth = LibraryGroupMode('modifiedMonth');
  static const myRating = LibraryGroupMode('myRating');
  static const owner = LibraryGroupMode('owner');
  static const reader = LibraryGroupMode('reader');
  static const readingStatus = LibraryGroupMode('readingStatus');
  static const completed = LibraryGroupMode('completed');
  static const completedDate = LibraryGroupMode('completedDate');
  static const completedMonth = LibraryGroupMode('completedMonth');
  static const completedYear = LibraryGroupMode('completedYear');
  static const readDate = LibraryGroupMode('readDate');
  static const readMonth = LibraryGroupMode('readMonth');
  static const readYear = LibraryGroupMode('readYear');
  static const isSigned = LibraryGroupMode('isSigned');
  static const signedBy = LibraryGroupMode('signedBy');
  static const purchaseDate = LibraryGroupMode('purchaseDate');
  static const purchaseMonth = LibraryGroupMode('purchaseMonth');
  static const purchaseYear = LibraryGroupMode('purchaseYear');
  static const purchaseStore = LibraryGroupMode('purchaseStore');
  static const soldDate = LibraryGroupMode('soldDate');
  static const soldMonth = LibraryGroupMode('soldMonth');
  static const soldYear = LibraryGroupMode('soldYear');
  static const storageDevice = LibraryGroupMode('storageDevice');
  static const dustJacket = LibraryGroupMode('dustJacket');
  static const subject = LibraryGroupMode('subject');
  static const tags = LibraryGroupMode('tags');
  static const bagBoardDate = LibraryGroupMode('bagBoardDate');
  static const bagBoardMonth = LibraryGroupMode('bagBoardMonth');
  static const bagBoardYear = LibraryGroupMode('bagBoardYear');
  static const watchDate = LibraryGroupMode('watchDate');
  static const watchMonth = LibraryGroupMode('watchMonth');
  static const watchYear = LibraryGroupMode('watchYear');
  static const watched = LibraryGroupMode('watched');
  static const watchedWhere = LibraryGroupMode('watchedWhere');

  static const values = [
    series, storyArc, character, title, publisher, year, audienceRating, color, genre, platform, developer, country, language, ageRating, crossover, imprint, seriesGroup, movieOrTvSeries, releaseDate, releaseMonth, releaseYear, publicationPlace, originalReleaseDate, originalReleaseMonth, originalReleaseYear, originalCountry, originalLanguage, originalPublicationDate, originalPublicationMonth, originalPublicationYear, originalPublicationPlace, originalPublisher, recordingDate, recordingMonth, recordingYear, coverDate, coverMonth, coverYear,
    audioTracks, boxSet, completeness, valueLocked, dustJacketCondition, distributor, instrument, isLive, mediaCondition, rpm, spars, soundType, studio, vinylColor, toySubtype, toyType, edition, audiobookAbridged, firstEdition, narrator, paperType, printedBy, editionReleaseDate, editionReleaseMonth, editionReleaseYear, extras, format, hdr, layers, packaging, regions, screenRatios, subtitles,
    actor, chorus, composer, composition, conductor, engineer, director, musician, orchestra, photography, producer, writer, creator, artist, penciller, inker, colorist, painter, letterer, separator, layouts, translator, plotter, scripter, coverArtist, coverPenciller, coverPainter, coverInker, coverColorist, coverSeparator, editor, editorInChief, forewordAuthor, ghostWriter, illustrator,
    location, ownership, addedDate, addedMonth, addedYear, collectionStatus, grade, condition, rawOrSlabbed, isKeyComic, imageType, modifiedDate, modifiedMonth, myRating, owner, reader, readingStatus, completed, completedDate, completedMonth, completedYear, readDate, readMonth, readYear, isSigned, signedBy, purchaseDate, purchaseMonth, purchaseYear, purchaseStore, soldDate, soldMonth, soldYear, storageDevice, dustJacket, subject, tags, bagBoardDate, bagBoardMonth, bagBoardYear, watchDate, watchMonth, watchYear, watched, watchedWhere,
  ];
}

extension type const LibrarySortColumn(String name) implements String {
  static const status = LibrarySortColumn('status');
  static const title = LibrarySortColumn('title');
  static const series = LibrarySortColumn('series');
  static const issue = LibrarySortColumn('issue');
  static const storyArc = LibrarySortColumn('storyArc');
  static const variant = LibrarySortColumn('variant');
  static const format = LibrarySortColumn('format');
  static const publisher = LibrarySortColumn('publisher');
  static const releaseDate = LibrarySortColumn('releaseDate');
  static const barcode = LibrarySortColumn('barcode');
  static const grade = LibrarySortColumn('grade');
  static const rawOrSlabbed = LibrarySortColumn('rawOrSlabbed');
  static const gradingCompany = LibrarySortColumn('gradingCompany');
  static const condition = LibrarySortColumn('condition');
  static const price = LibrarySortColumn('price');
  static const location = LibrarySortColumn('location');
  static const collectionStatus = LibrarySortColumn('collectionStatus');
  static const wishlist = LibrarySortColumn('wishlist');
  static const keyComic = LibrarySortColumn('keyComic');
  static const added = LibrarySortColumn('added');
  static const updated = LibrarySortColumn('updated');
  static const country = LibrarySortColumn('country');
  static const language = LibrarySortColumn('language');
  static const pageCount = LibrarySortColumn('pageCount');
  static const ageRating = LibrarySortColumn('ageRating');
  static const imprint = LibrarySortColumn('imprint');

  static const values = [
    status, title, series, issue, storyArc, variant, format, publisher, releaseDate, barcode, grade, rawOrSlabbed, gradingCompany, condition, price, location, collectionStatus, wishlist, keyComic, added, updated, country, language, pageCount, ageRating, imprint,
  ];
}

extension type const LibraryTableColumn(String name) implements String {
  static const status = LibraryTableColumn('status');
  static const cover = LibraryTableColumn('cover');
  static const frontCover = LibraryTableColumn('frontCover');
  static const backCover = LibraryTableColumn('backCover');
  static const hasFront = LibraryTableColumn('hasFront');
  static const hasBack = LibraryTableColumn('hasBack');
  static const extraImages = LibraryTableColumn('extraImages');
  static const author = LibraryTableColumn('author');
  static const artist = LibraryTableColumn('artist');
  static const album = LibraryTableColumn('album');
  static const title = LibraryTableColumn('title');
  static const issue = LibraryTableColumn('issue');
  static const variant = LibraryTableColumn('variant');
  static const format = LibraryTableColumn('format');
  static const publisher = LibraryTableColumn('publisher');
  static const label = LibraryTableColumn('label');
  static const catalogNumber = LibraryTableColumn('catalogNumber');
  static const platform = LibraryTableColumn('platform');
  static const developer = LibraryTableColumn('developer');
  static const releaseDate = LibraryTableColumn('releaseDate');
  static const releasePlatform = LibraryTableColumn('releasePlatform');
  static const barcode = LibraryTableColumn('barcode');
  static const discCount = LibraryTableColumn('discCount');
  static const trackCount = LibraryTableColumn('trackCount');
  static const trackLength = LibraryTableColumn('trackLength');
  static const vinylColor = LibraryTableColumn('vinylColor');
  static const rpm = LibraryTableColumn('rpm');
  static const grade = LibraryTableColumn('grade');
  static const condition = LibraryTableColumn('condition');
  static const completion = LibraryTableColumn('completion');
  static const price = LibraryTableColumn('price');
  static const value = LibraryTableColumn('value');
  static const location = LibraryTableColumn('location');
  static const readStatus = LibraryTableColumn('readStatus');
  static const rating = LibraryTableColumn('rating');
  static const wishlist = LibraryTableColumn('wishlist');
  static const added = LibraryTableColumn('added');
  static const updated = LibraryTableColumn('updated');
  static const country = LibraryTableColumn('country');
  static const language = LibraryTableColumn('language');
  static const pageCount = LibraryTableColumn('pageCount');
  static const ageRating = LibraryTableColumn('ageRating');
  static const imprint = LibraryTableColumn('imprint');

  static const values = [
    status, cover, frontCover, backCover, hasFront, hasBack, extraImages, author, artist, album, title, issue, variant, format, publisher, label, catalogNumber, platform, developer, releaseDate, releasePlatform, barcode, discCount, trackCount, trackLength, vinylColor, rpm, grade, condition, completion, price, value, location, readStatus, rating, wishlist, added, updated, country, language, pageCount, ageRating, imprint,
  ];
}

enum LibrarySortFieldGroup { main, value, edition, personal }
