import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/embedded_tool.dart';
import '../../domain/repositories/tools_repository.dart';

class ToolsRepositoryImpl implements ToolsRepository {
  ToolsRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Either<Failure, Unit>> saveResult({
    required EmbeddedTool tool,
    String? motorcycleId,
    String? summary,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return const Left(AuthFailure());
      await _client.from('tool_results').insert({
        'user_id': uid,
        'tool': tool.id,
        'motorcycle_id': motorcycleId,
        'summary': summary,
        'payload': payload,
      });
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
