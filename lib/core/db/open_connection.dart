export 'open_connection_stub.dart'
    if (dart.library.io) 'open_connection_native.dart'
    if (dart.library.html) 'open_connection_web.dart';
