import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scannerx_example/pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = createTheme();
    setSystemChrome(theme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      themeMode: ThemeMode.dark,
      darkTheme: theme,
      routes: {
        'camera': (context) => const ScannerPage(),
        'info': (context) => const InfoPage(),
      },
    );
  }

  ThemeData createTheme() {
    return ThemeData(
      colorSchemeSeed: Colors.greenAccent,
      brightness: Brightness.dark,
      useMaterial3: true,
    );
  }

  setSystemChrome(ThemeData theme) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: ElevationOverlay.applySurfaceTint(
        theme.colorScheme.background,
        theme.colorScheme.surfaceTint,
        3,
      ),
    ));
  }
}
