import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

<<<<<<< HEAD
import 'core/routing/app_router.dart';
import 'features/parent/presentation/widgets/parent_ui_constants.dart';

void main() {
=======
import 'core/storage/hive_boxes.dart';
import 'features/parent/presentation/screens/parent_navigation_shell.dart';
import 'features/parent/presentation/widgets/parent_ui_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
>>>>>>> 19d165199753a305744625bfe0dad9dd69efa725
  runApp(const ProviderScope(child: SafeRideApp()));
}

class SafeRideApp extends StatelessWidget {
  const SafeRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeRide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: ParentUiColors.orange),
        scaffoldBackgroundColor: ParentUiColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: ParentUiColors.background,
          foregroundColor: ParentUiColors.textDark,
          elevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: ParentUiColors.lightOrange,
          labelTextStyle: WidgetStateProperty.all(
            ParentUiTextStyles.caption.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ),
<<<<<<< HEAD
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
        return AppRouter.onGenerateRoute(settings);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Splash screen
// ---------------------------------------------------------------------------

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2400), _navigate);
  }

  void _navigate() {
    if (_disposed || !mounted) return;
    Navigator.pushReplacementNamed(context, '/auth/login');
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUiColors.orange,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 96,
                  width: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(ParentUiRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_bus_rounded,
                    color: ParentUiColors.orange,
                    size: 52,
                  ),
                ),
                const SizedBox(height: ParentUiSpacing.lg),
                const Text(
                  'SafeRide',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: ParentUiSpacing.xs),
                Text(
                  'Safe journeys for every child',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
=======
      home: const ParentNavigationShell(),
>>>>>>> 19d165199753a305744625bfe0dad9dd69efa725
    );
  }
}
