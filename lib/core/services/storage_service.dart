import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String favoritesBox = 'favorites';
  static const String playlistsBox = 'playlists';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(favoritesBox);
    await Hive.openBox(playlistsBox);
    await Hive.openBox(settingsBox);
  }
}
