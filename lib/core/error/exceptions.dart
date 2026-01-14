class ServerException implements Exception {
  final String message;
  
  ServerException(this.message);
  
  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  
  CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class PurchaseException implements Exception {
  final String message;
  
  PurchaseException(this.message);
  
  @override
  String toString() => 'PurchaseException: $message';
}

class DownloadException implements Exception {
  final String message;
  
  DownloadException(this.message);
  
  @override
  String toString() => 'DownloadException: $message';
}

class PlayerException implements Exception {
  final String message;
  
  PlayerException(this.message);
  
  @override
  String toString() => 'PlayerException: $message';
}