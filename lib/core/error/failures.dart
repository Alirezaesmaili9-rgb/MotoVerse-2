import 'package:equatable/equatable.dart';

/// Domain-level failure. Repositories return `Either<Failure, T>` so the
/// presentation layer never deals with raw exceptions.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'خطا در ارتباط با سرور']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'خطا در احراز هویت']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'اتصال اینترنت برقرار نیست']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'خطا در خواندن اطلاعات محلی']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'خطای ناشناخته رخ داد']);
}
