import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class PurchaseFailure extends Failure {
  const PurchaseFailure(super.message);
}

class DownloadFailure extends Failure {
  const DownloadFailure(super.message);
}

class PlayerFailure extends Failure {
  const PlayerFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}