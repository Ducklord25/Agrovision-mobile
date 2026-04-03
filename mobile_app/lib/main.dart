import 'package:flutter/material.dart';

import 'screens/analytics_screen.dart';
import 'screens/prediction_screen.dart';
import 'services/local_prediction_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AgroVisionApp());
}

class AgroVisionApp extends StatelessWidget {
  const AgroVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroVision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0;
  bool _showHome = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _opacity = 1;
      });
    });

    Future<void>.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showHome = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showHome) {
      return const AgroVisionHome();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOut,
          opacity: _opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 124,
                height: 124,
              ),
              const SizedBox(height: 16),
              const Text(
                'AgroVision',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AgroVisionHome extends StatefulWidget {
  const AgroVisionHome({super.key});

  @override
  State<AgroVisionHome> createState() => _AgroVisionHomeState();
}

class _AgroVisionHomeState extends State<AgroVisionHome> {
  int _currentIndex = 0;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = LocalPredictionService.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            ),
          );
        }

        final screens = [
          PredictionScreen(service: LocalPredictionService.instance),
          AnalyticsScreen(service: LocalPredictionService.instance),
        ];

        return Scaffold(
          body: screens[_currentIndex],
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFEFC),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFDDEBDD)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF123524).withOpacity(0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      label: 'Prediction',
                      icon: Icons.spa_outlined,
                      activeIcon: Icons.spa,
                      isActive: _currentIndex == 0,
                      onTap: () {
                        setState(() {
                          _currentIndex = 0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _NavItem(
                      label: 'Analytics',
                      icon: Icons.bar_chart_outlined,
                      activeIcon: Icons.bar_chart,
                      isActive: _currentIndex == 1,
                      onTap: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                  )
                : null,
            color: isActive ? null : const Color(0xFFF3F8F3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 20,
                color: isActive ? Colors.white : const Color(0xFF5F7364),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : const Color(0xFF48614F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
