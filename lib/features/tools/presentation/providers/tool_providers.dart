import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../garage/presentation/providers/garage_providers.dart';
import '../../data/repositories/tools_repository_impl.dart';
import '../../domain/entities/tool_context.dart';
import '../../domain/repositories/tools_repository.dart';

final toolsRepositoryProvider = Provider<ToolsRepository>((ref) {
  return ToolsRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// Context injected into every embedded tool, derived from the user's primary
/// motorcycle. Recomputes automatically when the garage changes.
final toolContextProvider = Provider<ToolContext>((ref) {
  final bike = ref.watch(primaryMotorcycleProvider);
  return ToolContext.fromMotorcycle(bike);
});
