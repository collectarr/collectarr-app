import 'package:flutter/foundation.dart';

/// Native phone/tablet UI. Web keeps its desktop controls at every width.
bool get isMobileApp =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);
