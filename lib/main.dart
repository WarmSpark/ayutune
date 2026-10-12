import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/catalog_screen.dart';
import 'screens/player_screen.dart';
import 'services/audio_player_service.dart';
import 'services/offline_service.dart';
import 'services/playlist_service.dart';
import 'theme/theme_provider.dart';
import 'widgets/retro_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OfflineService().init();
  await PlaylistService().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerService()),
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
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

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
              RetroWindowHeader(
                theme: theme,
                title: 'ayutune.apk',
                onFilesTap: () => setState(() => _selectedTabIndex = 1),
                onThemeTap: () => setState(() => _selectedTabIndex = 0),
              ),
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
