import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/wallet_transaction.dart';

abstract interface class WalletRepository {
  Future<Either<Failure, int>> getBalance();

  Future<Either<Failure, List<WalletTransaction>>> getTransactions();

  /// Credits the wallet via the `wallet_recharge` RPC after a successful
  /// gateway payment. Returns the new balance.
  Future<Either<Failure, int>> recharge({
    required int amount,
    String? reference,
  });
}
