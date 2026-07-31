// Re-export shared book domain types so that book-catalog code that
// already imports this file continues to compile unchanged.
export 'package:collectarr_app/features/library/shared/book/book_domain.dart'
    show BookVariantRef, BookRelease;
