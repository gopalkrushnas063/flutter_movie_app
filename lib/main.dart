// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:movie_app/features/users/views/user_screen.dart';
// import 'package:movie_app/services/sync_service.dart';

// late String tempPath;
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// // Connectivity provider
// final connectivityProvider = StateProvider<ConnectivityResult>((ref) {
//   return ConnectivityResult.none; // Default value
// });

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize sync service
//   await SyncService.initialize();

//   // Get initial connectivity
//   final connectivity = Connectivity();
//   final initialConnectivity = await connectivity.checkConnectivity();

//   // Create a single container
//   final container = ProviderContainer();

//   // Set the initial connectivity state if available
//   if (initialConnectivity.isNotEmpty) {
//     container.read(connectivityProvider.notifier).state = initialConnectivity.first;
//   } else {
//     // Default to offline if we can't determine the state
//     container.read(connectivityProvider.notifier).state = ConnectivityResult.none;
//   }

//   // Monitor connectivity changes
//   connectivity.onConnectivityChanged.listen((results) {
//     if (results.isNotEmpty) {
//       final result = results.first;
//       final previousResult = container.read(connectivityProvider);
//       container.read(connectivityProvider.notifier).state = result;

//       // Logging connection state changes for debugging
//       if (previousResult == ConnectivityResult.none && result != ConnectivityResult.none) {
//         debugPrint("🌐 Connectivity changed to online: ${result.name}");
//         SyncService.triggerSync();
//       } else if (previousResult != ConnectivityResult.none && result == ConnectivityResult.none) {
//         debugPrint("📴 Device is now offline");
//       }
//     }
//   });

//   // Use the container with UncontrolledProviderScope
//   runApp(
//     UncontrolledProviderScope(
//       container: container,
//       child: const MyApp(),
//     )
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       title: 'Movie App',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const UserScreen(),
//     );
//   }
// }


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/data/local/database.dart';
import 'package:movie_app/features/users/views/user_screen.dart';
import 'package:movie_app/services/sync_service.dart';

late String tempPath;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Connectivity provider
final connectivityProvider = StateProvider<ConnectivityResult>((ref) {
  return ConnectivityResult.none; // Default value
});

// Database provider
final databaseInitializedProvider = StateProvider<bool>((ref) {
  return false;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Get the database instance early but don't initialize fully
  final database = AppDatabase();

  // Get initial connectivity - only do a quick check
  final connectivity = Connectivity();
  final initialConnectivity = await connectivity.checkConnectivity();

  // Create a single container
  final container = ProviderContainer();

  // Set the initial connectivity state if available
  if (initialConnectivity.isNotEmpty) {
    container.read(connectivityProvider.notifier).state = initialConnectivity.first;
  } else {
    // Default to offline if we can't determine the state
    container.read(connectivityProvider.notifier).state = ConnectivityResult.none;
  }

  // Launch the app immediately, without waiting for more initialization
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    )
  );
  
  // Perform heavy initialization tasks after UI is visible
  Future.delayed(const Duration(seconds: 2), () async {
    // Initialize database fully
    await database.initializeDatabase();
    container.read(databaseInitializedProvider.notifier).state = true;
    
    // Now initialize sync service with a delay
    await SyncService.initialize();
    
    // Setup connectivity listener
    connectivity.onConnectivityChanged.listen((results) {
      if (results.isNotEmpty) {
        final result = results.first;
        final previousResult = container.read(connectivityProvider);
        container.read(connectivityProvider.notifier).state = result;

        // Logging connection state changes for debugging
        if (previousResult == ConnectivityResult.none && result != ConnectivityResult.none) {
          debugPrint("🌐 Connectivity changed to online: ${result.name}");
          // Don't trigger sync immediately, give the connection time to stabilize
          Future.delayed(const Duration(seconds: 2), () {
            SyncService.triggerSync();
          });
        } else if (previousResult != ConnectivityResult.none && result == ConnectivityResult.none) {
          debugPrint("📴 Device is now offline");
        }
      }
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Movie App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Start with splash screen
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Allow splash screen to display for at least 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your app logo
            Icon(
              Icons.movie_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading App...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}