
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/features/users/views/user_screen.dart';
import 'package:movie_app/services/sync_service.dart';

late String tempPath;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize connectivity listener
  final connectivity = Connectivity();
  connectivity.onConnectivityChanged.listen((result) {
    // You can use a provider to update connectivity state globally
  });
  
  await SyncService.initialize();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UserScreen(), // Set UserScreen as the initial screen
    );
  }
}