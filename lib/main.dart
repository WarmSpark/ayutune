import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'screens/catalog_screen.dart';
import 'screens/player_screen.dart';
import 'services/audio_handler.dart';
import 'services/audio_player_service.dart';
import 'services/offline_service.dart';
import 'services/playlist_service.dart';
import 'theme/theme_provider.dart';
import 'widgets/retro_window.dart';

late final AyutuneAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  audioHandler = await AudioService.init(
    builder: () => AyutuneAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.warmspark.ayutune.ayutune.channel.audio',
      androidNotificationChannelName: 'Ayutune Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'drawable/ic_music_note',
      notificationColor: Color(0xFF132240),
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AudioPlayerService(audioHandler: audioHandler),
        ),
      ],
      child: const AyutuneApp(),
    ),
  );
}

class AyutuneApp extends StatelessWidget {
  const AyutuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Ayutune',
      debugShowCheckedModeBanner: false,
      home: AyutuneHomeScreen(),
    );
  }
}

class AyutuneHomeScreen extends StatefulWidget {
  const AyutuneHomeScreen({super.key});

  @override
  State<AyutuneHomeScreen> createState() => _AyutuneHomeScreenState();
}

class _AyutuneHomeScreenState extends State<AyutuneHomeScreen> {
  int _selectedTabIndex = 1;

  @override
  void initState() {
    super.initState();
    OfflineService().init();
    PlaylistService().init();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: theme.background,
            border: Border.all(color: theme.ink, width: 3),
          ),
          child: Column(
            children: [
              RetroNavTabs(
                theme: theme,
                selectedTab: _selectedTabIndex,
                onTabSelected: (idx) => setState(() => _selectedTabIndex = idx),
              ),
              Expanded(
                child: IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    const PlayerScreen(),
                    CatalogScreen(
                      onOpenPlayer: () => setState(() => _selectedTabIndex = 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
