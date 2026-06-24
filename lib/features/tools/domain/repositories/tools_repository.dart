import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/embedded_tool.dart';

/// Persists results emitted by an embedded tool through the bridge.
abstract interface class ToolsRepository {
  Future<Either<Failure, Unit>> saveResult({
    required EmbeddedTool tool,
    String? motorcycleId,
    String? summary,
    required Map<String, dynamic> payload,
  });
}
