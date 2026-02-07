import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global provider for AudioHandler.
/// This must be overridden in the main functionality.
final audioHandlerProvider = Provider<AudioHandler>((ref) {
  throw UnimplementedError('AudioHandler provider was not initialized');
});
