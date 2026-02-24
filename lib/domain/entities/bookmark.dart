import 'package:equatable/equatable.dart';

class Bookmark extends Equatable {
  final String id;
  final String videoId;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.videoId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, videoId, createdAt];
}
