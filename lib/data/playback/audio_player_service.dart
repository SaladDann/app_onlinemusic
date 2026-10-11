// lib/data/playback/audio_player_service.dart
import '../play_mode.dart';
import '../song.dart';

enum PlayerStateEnum {
  stopped,
  buffering,
  playing,
  paused,
  completed,
}

class FavoriteToggledFromNotification {
  const FavoriteToggledFromNotification({
    required this.songId,
    required this.isFavorite,
  });

  final String songId;
  final bool isFavorite;
}

abstract class AudioPlayerService {
  Stream<PlayerStateEnum> get playerStateStream;
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<Song?> get currentSongStream;
  Stream<FavoriteToggledFromNotification> get favoriteToggledStream;

  Future<void> playSong(Song song);

  Future<void> setPlaylist(
    List<Song> playlist, {
    int initialIndex = 0,
    Duration startPosition = Duration.zero,
  });

  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> skipToNext();
  Future<void> skipToPrevious();
  Future<void> seek(Duration position);
  Future<void> setSpeed(double speed);
  Future<void> setPlayMode(PlayMode mode);
  Future<void> setFavorite(bool isFavorite);
  Future<void> initializeDeviceCapabilities(List<Song> songs);
  Future<void> updatePlaylistOrder(List<Song> playlist);
  Future<void> dispose();
}
