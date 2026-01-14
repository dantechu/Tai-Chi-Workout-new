import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/audio_track.dart';

abstract class AudioRepository {
  Future<Either<Failure, List<AudioTrack>>> getAllTracks();
  Future<Either<Failure, List<AudioTrack>>> getTracksByType(AudioTrackType type);
  Future<Either<Failure, List<AudioTrack>>> getTracksByLocale(String locale);
  Future<Either<Failure, AudioTrack>> getTrack(String id);
  Future<Either<Failure, bool>> cacheAudioTracks(List<AudioTrack> tracks);
  Future<Either<Failure, List<AudioTrack>>> getCachedAudioTracks();
  Future<Either<Failure, bool>> playTrack(String id);
  Future<Either<Failure, bool>> pauseTrack();
  Future<Either<Failure, bool>> stopTrack();
  Future<Either<Failure, bool>> setVolume(double volume);
  Stream<AudioTrack?> get currentlyPlayingStream;
  Stream<Duration> get positionStream;
  Stream<double> get volumeStream;
}