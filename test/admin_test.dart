import 'package:flutter_test/flutter_test.dart';
import 'package:motoverse/features/admin/domain/entities/admin_stats.dart';
import 'package:motoverse/features/admin/domain/entities/admin_user.dart';
import 'package:motoverse/features/auth/domain/entities/app_user.dart';

void main() {
  group('AppUser role', () {
    test('isAdmin reflects role', () {
      const admin = AppUser(id: '1', role: 'admin');
      const rider = AppUser(id: '2');
      expect(admin.isAdmin, isTrue);
      expect(rider.isAdmin, isFalse);
      expect(rider.role, 'rider');
    });
  });

  group('AdminUser', () {
    test('isAdmin reflects role', () {
      const u = AdminUser(id: '1', role: 'admin');
      expect(u.isAdmin, isTrue);
    });
  });

  group('AdminStats', () {
    test('defaults to zero', () {
      const s = AdminStats();
      expect(s.users, 0);
      expect(s.revenue, 0);
    });
  });
}
