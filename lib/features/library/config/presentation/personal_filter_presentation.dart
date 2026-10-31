class LibraryFilterOptionLabels {
  const LibraryFilterOptionLabels({
    this.entriesAll = 'All items',
    this.entriesEntry = 'Entry only',
    this.entriesWishlist = 'Wishlist only',
    this.entriesForSale = 'For sale',
    this.entriesOnOrder = 'On order',
    this.trackingAny = 'Any tracking status',
    this.trackingNotTracked = 'Not tracked',
    this.loanAny = 'Any loan status',
    this.loanOnLoan = 'Currently on loan',
    this.loanAvailable = 'Available locally',
    this.dateUpdated = 'Updated',
    this.datePurchased = 'Purchased',
    this.dateStarted = 'Started',
    this.dateFinished = 'Finished',
  });

  final String entriesAll;
  final String entriesEntry;
  final String entriesWishlist;
  final String entriesForSale;
  final String entriesOnOrder;
  final String trackingAny;
  final String trackingNotTracked;
  final String loanAny;
  final String loanOnLoan;
  final String loanAvailable;
  final String dateUpdated;
  final String datePurchased;
  final String dateStarted;
  final String dateFinished;
}
