import 'package:collectarr_app/core/models/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only a Core admin role grants admin tools', () {
    expect(AuthUser.fromJson(const {'role': 'admin'}).isAdmin, isTrue);
    expect(AuthUser.fromJson(const {'role': 'editor'}).isAdmin, isFalse);
    expect(AuthUser.fromJson(const {'role': 'viewer'}).isAdmin, isFalse);
    expect(AuthUser.fromJson(const {}).isAdmin, isFalse);
  });
}
