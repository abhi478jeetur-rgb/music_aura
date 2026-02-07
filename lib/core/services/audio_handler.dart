import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => AuraAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.lenovo.aura.channel.audio',
      androidNotificationChannelName: 'Aura Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

enum RepeatMode {
  off,
  all,
  one,
}

class AuraAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  
  // Playback state
  bool _isShuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  List<int> _originalIndices = [];
  
  AuraAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenToPlaybackState();
    _listenForSequenceStateChanges();
  }

  // Getters for current state
  bool get isShuffleEnabled => _isShuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;
  AudioPlayer get player => _player;

  /// Play a single media item
  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);
    playbackState.add(playbackState.value.copyWith(
      controls: _getControls(),
      processingState: AudioProcessingState.loading,
    ));

    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(mediaItem.extras!['url']))
      );
      await _player.play();
    } catch (e) {
      print("Error playing audio: $e");
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
      ));
    }
  }

  /// Set and play a queue of media items
  Future<void> playQueue(List<MediaItem> items, {int initialIndex = 0}) async {
    if (items.isEmpty) return;

    // Store original indices for shuffle
    _originalIndices = List.generate(items.length, (index) => index);

    // Set the queue
    queue.add(items);

    // Create audio sources
    final audioSources = items.map((item) {
      return AudioSource.uri(
        Uri.parse(item.extras!['url']),
        tag: item,
      );
    }).toList();

    try {
      // Create concatenating audio source for playlist
      await _player.setAudioSource(
        ConcatenatingAudioSource(children: audioSources),
        initialIndex: initialIndex,
      );
      
      await _player.play();
      
      // Update current media item
      if (initialIndex < items.length) {
        mediaItem.add(items[initialIndex]);
      }
    } catch (e) {
      print("Error playing queue: $e");
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
      ));
    }
  }

  /// Add item to queue
  @override
  Future<void> addQueueItem(MediaItem item) async {
    final newQueue = [...queue.value, item];
    queue.add(newQueue);

    final audioSource = AudioSource.uri(
      Uri.parse(item.extras!['url']),
      tag: item,
    );

    if (_player.audioSource is ConcatenatingAudioSource) {
      await (_player.audioSource as ConcatenatingAudioSource).add(audioSource);
    }
  }

  /// Add multiple items to queue
  Future<void> addQueueItems(List<MediaItem> items) async {
    if (items.isEmpty) return;

    final newQueue = [...queue.value, ...items];
    queue.add(newQueue);

    final audioSources = items.map((item) {
      return AudioSource.uri(
        Uri.parse(item.extras!['url']),
        tag: item,
      );
    }).toList();

    if (_player.audioSource is ConcatenatingAudioSource) {
      await (_player.audioSource as ConcatenatingAudioSource)
          .addAll(audioSources);
    }
  }

  /// Remove item from queue
  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= queue.value.length) return;

    final newQueue = [...queue.value];
    newQueue.removeAt(index);
    queue.add(newQueue);

    if (_player.audioSource is ConcatenatingAudioSource) {
      await (_player.audioSource as ConcatenatingAudioSource).removeAt(index);
    }
  }

  /// Clear queue
  Future<void> clearQueue() async {
    queue.add([]);
    await _player.stop();
  }

  /// Skip to next track
  @override
  Future<void> skipToNext() async {
    if (_repeatMode == RepeatMode.one) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }

    if (_player.hasNext) {
      await _player.seekToNext();
    } else if (_repeatMode == RepeatMode.all) {
      await _player.seek(Duration.zero, index: 0);
    }
  }

  /// Skip to previous track
  @override
  Future<void> skipToPrevious() async {
    if (_repeatMode == RepeatMode.one) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }

    // If we're more than 3 seconds into the song, restart it
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else if (_repeatMode == RepeatMode.all) {
      // Go to last track
      final lastIndex = queue.value.length - 1;
      await _player.seek(Duration.zero, index: lastIndex);
    }
  }

  /// Skip to specific queue item
  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    await _player.seek(Duration.zero, index: index);
    await _player.play();
  }

  /// Toggle shuffle
  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    
    if (_isShuffleEnabled) {
      await _player.setShuffleModeEnabled(true);
    } else {
      await _player.setShuffleModeEnabled(false);
    }
    
    // Update playback state to reflect shuffle change
    playbackState.add(playbackState.value.copyWith(
      shuffleMode: _isShuffleEnabled 
          ? AudioServiceShuffleMode.all 
          : AudioServiceShuffleMode.none,
    ));
  }

  /// Set shuffle mode
  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _isShuffleEnabled = shuffleMode == AudioServiceShuffleMode.all;
    await _player.setShuffleModeEnabled(_isShuffleEnabled);
    
    playbackState.add(playbackState.value.copyWith(
      shuffleMode: shuffleMode,
    ));
  }

  /// Cycle repeat mode (off -> all -> one -> off)
  Future<void> cycleRepeatMode() async {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        await _player.setLoopMode(LoopMode.all);
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        await _player.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        await _player.setLoopMode(LoopMode.off);
        break;
    }

    playbackState.add(playbackState.value.copyWith(
      repeatMode: _audioServiceRepeatMode(_repeatMode),
    ));
  }

  /// Set repeat mode
  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _repeatMode = RepeatMode.off;
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.all:
        _repeatMode = RepeatMode.all;
        await _player.setLoopMode(LoopMode.all);
        break;
      case AudioServiceRepeatMode.one:
        _repeatMode = RepeatMode.one;
        await _player.setLoopMode(LoopMode.one);
        break;
      default:
        break;
    }

    playbackState.add(playbackState.value.copyWith(
      repeatMode: repeatMode,
    ));
  }

  /// Get audio service repeat mode from our repeat mode
  AudioServiceRepeatMode _audioServiceRepeatMode(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return AudioServiceRepeatMode.none;
      case RepeatMode.all:
        return AudioServiceRepeatMode.all;
      case RepeatMode.one:
        return AudioServiceRepeatMode.one;
    }
  }

  /// Get current controls based on state
  List<MediaControl> _getControls() {
    final playing = _player.playing;
    return [
      MediaControl.skipToPrevious,
      if (playing) MediaControl.pause else MediaControl.play,
      MediaControl.stop,
      MediaControl.skipToNext,
    ];
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: _getControls(),
        systemActions: const {
          MediaAction.seek,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
        shuffleMode: _isShuffleEnabled 
            ? AudioServiceShuffleMode.all 
            : AudioServiceShuffleMode.none,
        repeatMode: _audioServiceRepeatMode(_repeatMode),
      ));
    });
  }

  void _listenToPlaybackState() {
    _player.positionStream.listen((position) {
      final oldState = playbackState.value;
      playbackState.add(oldState.copyWith(updatePosition: position));
    });
    
    _player.durationStream.listen((duration) {
      final index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.processingState == ProcessingState.idle) return;
      
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  /// Listen for sequence state changes (track changes)
  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;

      final currentIndex = sequenceState.currentIndex;
      if (currentIndex != null && currentIndex < queue.value.length) {
        mediaItem.add(queue.value[currentIndex]);
      }

      playbackState.add(playbackState.value.copyWith(
        queueIndex: currentIndex,
      ));
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _player.dispose();
  }
}
