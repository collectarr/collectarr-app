import 'local_font_face.dart';

bool get canDiscoverLocalFonts => false;
bool get discoverFontsAtStartup => false;
Future<List<LocalFontFace>> discoverLocalFonts() async => [];
