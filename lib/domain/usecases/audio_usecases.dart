import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/audio_track.dart';
import '../repositories/audio_repository.dart';

class GetAudioTracks {
  final AudioRepository repository;

  GetAudioTracks(this.repository);

  Future<Either<Failure, List<AudioTrack>>> call() async {
    return await repository.getAllTracks();
  }
}

class GetAudioTracksByType {
  final AudioRepository repository;

  GetAudioTracksByType(this.repository);

  Future<Either<Failure, List<AudioTrack>>> call(AudioTrackType type) async {
    return await repository.getTracksByType(type);
  }
}

class PlayAudioTrack {
  final AudioRepository repository;

  PlayAudioTrack(this.repository);

  Future<Either<Failure, bool>> call(String trackId) async {
    return await repository.playTrack(trackId);
  }
}

class PauseAudio {
  final AudioRepository repository;

  PauseAudio(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.pauseTrack();
  }
}

class StopAudio {
  final AudioRepository repository;

  StopAudio(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.stopTrack();
  }
}

class SetAudioVolume {
  final AudioRepository repository;

  SetAudioVolume(this.repository);

  Future<Either<Failure, bool>> call(double volume) async {
    return await repository.setVolume(volume);
  }
}