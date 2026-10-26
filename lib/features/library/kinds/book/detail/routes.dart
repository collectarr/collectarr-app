const bookAuthorRoutePath = '/book/author/:name';

String bookAuthorLocation(String name) =>
    '/book/author/${Uri.encodeComponent(name)}';
