// // lib/Utilities/Routes/app_router.dart
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';


// class AppRouter {
//   final bool isLoggedIn;

//   AppRouter(this.isLoggedIn);

//   late final router = GoRouter(
//     navigatorKey: navigatorKey,
//     initialLocation: '/',
//     routes: [
//       GoRoute(
//         path: '/',
//         pageBuilder: (context, state) => MaterialPage(
//           key: state.pageKey,
//           child: isLoggedIn ? const HomePage() : WelcomeScreen(),
//         ),
//       ),
//       GoRoute(
//         path: '/course',
//         pageBuilder: (context, state) => MaterialPage(
//           key: state.pageKey,
//           child: AllCourseList(),
//         ),
//       ),
//       GoRoute(
//         path: '/wishlist',
//         pageBuilder: (context, state) => MaterialPage(
//           key: state.pageKey,
//           child: WishList(),
//         ),
//       ),
//       GoRoute(
//         path: '/account',
//         pageBuilder: (context, state) => MaterialPage(
//           key: state.pageKey,
//           child: const ProfileSection(),
//         ),
//       ),
//       GoRoute(
//         path: '/main_auth',
//         pageBuilder: (context, state) => MaterialPage(
//           key: state.pageKey,
//           child: MainAuthScreen(),
//         ),
//       ),
//       GoRoute(
//         path: '/login',
//         pageBuilder: (context, state) => MaterialPage(
//           key: state.pageKey,
//           child: LoginScreen(),
//         ),
//       ),
//       //HomePage
//       GoRoute(
//         path: '/home',
//         pageBuilder: (context, state) => MaterialPage(
//           key: state.pageKey,
//           child: HomePage(),
//         ),
//       ),
//     ],
//     errorPageBuilder: (context, state) => MaterialPage(
//       key: state.pageKey,
//       child: Scaffold(
//         body: Center(
//           child: Text('Error: ${state.error}'),
//         ),
//       ),
//     ),
//   );
// }
