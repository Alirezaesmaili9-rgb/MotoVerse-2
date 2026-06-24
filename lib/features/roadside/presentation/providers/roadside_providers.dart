import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/roadside_repository_impl.dart';
import '../../domain/entities/roadside_request.dart';
import '../../domain/repositories/roadside_repository.dart';

final roadsideRepositoryProvider = Provider<RoadsideRepository>((ref) {
  return RoadsideRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// Live updates for a specific roadside request (status / ETA / technician).
final roadsideRequestStreamProvider =
    StreamProvider.autoDispose.family<RoadsideRequest, String>((ref, id) {
  return ref.watch(roadsideRepositoryProvider).watch(id);
});

/// Past requests.
final roadsideHistoryProvider =
    FutureProvider.autoDispose<List<RoadsideRequest>>((ref) async {
  ref.watch(authStateChangesProvider);
  final res = await ref.watch(roadsideRepositoryProvider).getHistory();
  return res.fold((f) => throw Exception(f.message), (h) => h);
});

/// Creates a request; returns the new request id or throws message.
final createRoadsideProvider = Provider((ref) => _CreateRoadside(ref));

class _CreateRoadside {
  _CreateRoadside(this.ref);
  final Ref ref;

  Future<(String? id, String? error)> call(RoadsideKind kind) async {
    final res =
        await ref.read(roadsideRepositoryProvider).createRequest(kind: kind);
    return res.fold(
      (f) => (null, f.message),
      (req) {
        ref.invalidate(roadsideHistoryProvider);
        return (req.id, null);
      },
    );
  }
}
