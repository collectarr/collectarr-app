// Re-export shared book domain types so that book-catalog code that
// already imports this file continues to compile unchanged.
export 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart'
    show BookVariantRef, BookRelease;
