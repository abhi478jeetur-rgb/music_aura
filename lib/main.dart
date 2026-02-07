import 'package:aura/features/main/presentation/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/services/audio_handler.dart';
import 'package:aura/core/providers/audio_provider.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Audio Service
  final audioHandler = await initAudioService();
  
  // Initialize Hive Storage
  await StorageService.init();
  
  runApp(ProviderScope(
    overrides: [
      audioHandlerProvider.overrideWithValue(audioHandler),
    ],
    child: const AuraApp(),
  ));
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aura',
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
