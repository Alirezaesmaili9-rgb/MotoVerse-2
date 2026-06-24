import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';

/// Maps between the Supabase `auth.users` + `profiles` row and the [AppUser]
/// domain entity.
class AppUserModel {
  const AppUserModel._();

  static AppUser fromSupabase(User user, {Map<String, dynamic>? profile}) {
    return AppUser(
      id: user.id,
      phone: user.phone,
      email: user.email,
      fullName: profile?['full_name'] as String? ??
          user.userMetadata?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String? ??
          user.userMetadata?['avatar_url'] as String?,
      walletBalance: (profile?['wallet_balance'] as num?)?.toInt() ?? 0,
    );
  }

  static Map<String, dynamic> toProfileInsert(User user) => {
        'id': user.id,
        'phone': user.phone,
        'full_name': user.userMetadata?['full_name'],
      };
}
