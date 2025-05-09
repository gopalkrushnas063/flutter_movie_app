import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/Utilities/enums.dart';
import 'package:movie_app/data/local/database.dart';
import 'package:movie_app/data/local/db_provider.dart';
import 'package:movie_app/features/movies/views/movie_list_screen.dart';
import 'package:movie_app/features/offlineRecords/offline_records.dart';
import 'package:movie_app/features/users/controllers/unsynced_counter_provider.dart';
import 'package:movie_app/features/users/controllers/user_controller.dart';
import 'package:movie_app/features/users/viewModels/user_view_model.dart';
import 'package:movie_app/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart'; // Import to access the connectivity provider
import 'package:provider/provider.dart'; // Add this import
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController();
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userControllerProvider.notifier).getUsers();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(userControllerProvider.notifier).getUsers();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(userControllerProvider.notifier).getUsers(refresh: true);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    final connectivity = ref.watch(connectivityProvider);
    final isOnline = connectivity != ConnectivityResult.none;

    // Add the listener in the build method
    ref.listen<ConnectivityResult>(connectivityProvider, (previous, next) {
      if (previous != next &&
          next != ConnectivityResult.none &&
          !_isFirstLoad) {
        // If connectivity changed and we're now online, trigger a refresh
        _refreshController.requestRefresh();
      }
    });

    // Set first load to false after initial build
    if (_isFirstLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isFirstLoad = false;
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      // In your UserScreen's appBar
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),

        title: const Text(
          'Users',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          riverpod.Consumer(
            builder: (context, ref, child) {
              final unsyncedCount = ref.watch(unsyncedCountProvider).value ?? 0;

              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.storage),
                    if (unsyncedCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$unsyncedCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OfflineUsersScreen(),
                    ),
                  );
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  color: isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isOnline ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isOnline)
            Container(
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 16.0,
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'re offline. Showing cached data. New users will be saved locally and synced when you\'re back online.',
                      style: TextStyle(color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: _buildBody(userState),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        tooltip: 'Add User',
        heroTag: 'addUser',
        // Use a unique hero tag to avoid conflicts
        onPressed: () => _showAddUserDialog(context),
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
    );
  }

  // In your UserScreen's _buildBody method
  Widget _buildBody(UserViewModel userState) {
    if (userState.status == APIState.initial ||
        userState.status == APIState.loading &&
            (userState.users?.isEmpty ?? true)) {
      return const Center(child: CircularProgressIndicator());
    } else if (userState.status == APIState.error) {
      return Center(child: Text(userState.error ?? 'Error loading users'));
    } else if (userState.users == null || userState.users!.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemHeight = constraints.maxHeight / 6;

        return ListView.builder(
          controller: _scrollController,
          itemCount:
              userState.hasReachedMax
                  ? userState.users!.length
                  : userState.users!.length + 1,
          itemBuilder: (context, index) {
            if (index >= userState.users!.length) {
              return SizedBox(
                height: itemHeight,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            final user = userState.users![index];

            return SizedBox(
              height: itemHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MovieListScreen(userId: user.id),
                        ),
                      ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(user.avatar),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${user.firstName} ${user.lastName}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        user.email,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final jobController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Add User',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter name',
                  hintStyle: TextStyle(color: Colors.white54),
                  labelStyle: TextStyle(color: Colors.white54),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
              ),
              TextField(
                controller: jobController,
                decoration: const InputDecoration(
                  labelText: 'Job',
                  hintText: 'Enter job',
                  hintStyle: TextStyle(color: Colors.white54),
                  labelStyle: TextStyle(color: Colors.white54),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                ),
                style: const TextStyle(color: Colors.white),

                cursorColor: Colors.white,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            riverpod.Consumer(
              builder: (context, ref, _) {
                // Check connectivity directly when adding a user
                final connectivity = ref.watch(connectivityProvider);
                final isOnline = connectivity != ConnectivityResult.none;

                return TextButton(
                  onPressed: () async {
                    final name = nameController.text;
                    final job = jobController.text;

                    if (name.isEmpty || job.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    // final success = await ref
                    //     .read(userControllerProvider.notifier)
                    //     .addUser(name, job);

                    // if (mounted) {
                    //   Navigator.pop(context);
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //       content: Text(
                    //         success
                    //             ? isOnline
                    //                 ? 'User added successfully'
                    //                 : 'User saved offline and will sync when online'
                    //             : 'Failed to add user',
                    //       ),
                    //     ),
                    //   );

                    //   // Refresh the list
                    //   ref.read(userControllerProvider.notifier).getUsers();
                    // }

                    final success = await ref
                        .read(userControllerProvider.notifier)
                        .addUser(name, job);

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? isOnline
                                    ? 'User added successfully'
                                    : 'User saved offline and will sync when online'
                                : 'Failed to add user',
                          ),
                        ),
                      );
                      // Refresh the list
                      ref
                          .read(userControllerProvider.notifier)
                          .getUsers(refresh: true);
                          
                      // Update the unsynced count
                      ref.watch(unsyncedCountProvider);
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
