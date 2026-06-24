import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../models/wallet_transaction_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._client);

  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AuthException('Not authenticated');
    return id;
  }

  @override
  Future<Either<Failure, int>> getBalance() async {
    try {
      final row = await _client
          .from(AppConstants.tProfiles)
          .select('wallet_balance')
          .eq('id', _uid)
          .single();
      return Right((row['wallet_balance'] as num?)?.toInt() ?? 0);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<WalletTransaction>>> getTransactions() async {
    try {
      final rows = await _client
          .from(AppConstants.tWalletTransactions)
          .select()
          .eq('user_id', _uid)
          .order('created_at', ascending: false);
      return Right(rows.map(WalletTransactionModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, int>> recharge({
    required int amount,
    String? reference,
  }) async {
    try {
      final newBalance = await _client.rpc(
        'wallet_recharge',
        params: {'p_amount': amount, 'p_reference': reference},
      );
      return Right((newBalance as num).toInt());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
