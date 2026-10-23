import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppShellBrand extends StatelessWidget {
  const AppShellBrand({
    super.key,
    required this.icon,
    required this.kindTitle,
    required this.iconKey,
    required this.titleKey,
  });

  final IconData icon;
  final String kindTitle;
  final Key iconKey;
  final Key titleKey;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, key: iconKey, size: 22, color: Colors.white),
          const SizedBox(width: 7),
          Flexible(
            child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    'CARR ${kindTitle.toUpperCase()}',
                    key: titleKey,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: appFontFamily,
                      color: Colors.white,
                      fontSize: 22,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(_platformLabel,
                      key: const Key('app.brand-platform'),
                      style: TextStyle(
                          fontFamily: appFontFamily,
                          fontSize: 22,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          foreground: Paint()
                            ..color = Colors.white
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = .7)),
                ])),
          ),
        ],
      );

  String get _platformLabel {
    if (kIsWeb) return 'WEB';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => 'MOBILE',
      _ => 'DESKTOP',
    };
  }
}
