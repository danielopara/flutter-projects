import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wardrobe/screens/home_screen.dart';
import 'package:wardrobe/screens/lock_screen.dart';
import 'package:wardrobe/state/wardrobe_providers.dart';

class WardrobeApp extends StatelessWidget {
  const WardrobeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF5D4037);
    return MaterialApp(
      title: 'Wardrobe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: seed),
      darkTheme: ThemeData(colorSchemeSeed: seed, brightness: Brightness.dark),
      home: const AppGate(),
    );
  }
}

/// Shows a loader while the wardrobe loads, then either the lock screen (when
/// app lock is on and the session isn't unlocked) or the wardrobe itself.
class AppGate extends ConsumerStatefulWidget {
  const AppGate({super.key});

  /// How long the app may sit in the background before it locks again.
  /// Long enough that taking a photo with the camera doesn't trigger it.
  static const relockAfter = Duration(minutes: 2);

  @override
  ConsumerState<AppGate> createState() => _AppGateState();
}

class _AppGateState extends ConsumerState<AppGate> {
  bool _unlocked = false;
  DateTime? _hiddenAt;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () => _hiddenAt = DateTime.now(),
      onShow: () {
        final hiddenAt = _hiddenAt;
        _hiddenAt = null;
        if (hiddenAt != null &&
            DateTime.now().difference(hiddenAt) > AppGate.relockAfter) {
          setState(() => _unlocked = false);
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wardrobe = ref.watch(wardrobeProvider);
    return switch (wardrobe) {
      AsyncData(:final value) when value.appLock && !_unlocked => LockScreen(
        onUnlocked: () => setState(() => _unlocked = true),
      ),
      AsyncData() => const HomeScreen(),
      AsyncError(:final error) => _LoadError(
        error: error,
        onRetry: () => ref.invalidate(wardrobeProvider),
      ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text('Couldn\'t open your wardrobe.'),
              const SizedBox(height: 8),
              Text('$error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    );
  }
}
