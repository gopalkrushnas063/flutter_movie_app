import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/Utilities/enums.dart';
import 'package:movie_app/features/movies/views/movie_list_screen.dart';
import 'package:movie_app/features/users/controllers/user_controller.dart';
import 'package:movie_app/features/users/viewModels/user_view_model.dart';
import 'package:movie_app/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart'; // Import to access the connectivity provider

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userControllerProvider.notifier).getUsers();
    });
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
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    // Get the current connectivity status
    final connectivity = ref.watch(connectivityProvider);
    final isOnline = connectivity != ConnectivityResult.none;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          // Updated connectivity indicator with better visuals
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
          // Show a banner when offline
          if (!isOnline)
            Container(
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
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
        onPressed: () => _showAddUserDialog(context),
        child: const Icon(Icons.add),
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
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
          title: const Text('Add User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: jobController,
                decoration: const InputDecoration(labelText: 'Job'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            Consumer(
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
                      ref.read(userControllerProvider.notifier).getUsers();
                    }
                  },
                  child: const Text('Add'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}