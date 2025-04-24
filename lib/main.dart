import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/features/users/views/user_screen.dart';
import 'package:movie_app/services/sync_service.dart';

late String tempPath;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Connectivity provider
final connectivityProvider = StateProvider<ConnectivityResult>((ref) {
  return ConnectivityResult.none; // Default value
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sync service
  await SyncService.initialize();

  // Get initial connectivity
  final connectivity = Connectivity();
  final initialConnectivity = await connectivity.checkConnectivity();
  
  // Create a single container
  final container = ProviderContainer();
  
  // Set the initial connectivity state if available
  if (initialConnectivity.isNotEmpty) {
    container.read(connectivityProvider.notifier).state = initialConnectivity.first;
  }
  
  // Monitor connectivity changes
  connectivity.onConnectivityChanged.listen((results) {
    if (results.isNotEmpty) {
      final result = results.first;
      container.read(connectivityProvider.notifier).state = result;
      
      if (result != ConnectivityResult.none) {
        debugPrint("🌐 Connectivity changed to online: ${result.name}");
        SyncService.triggerSync();
      } else {
        debugPrint("📴 Device is now offline");
      }
    }
  });
  
  // Use the container with UncontrolledProviderScope
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    )
  );
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
      home: const UserScreen(),
    );
  }
}